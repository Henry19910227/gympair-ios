//
//  APIProtocol.swift
//  GymPair
//
//  Created by 廖冠翰 on 2020/11/18.
//

import Foundation
import RxSwift
import RxCocoa
import RxAlamofire
import Alamofire
import SwiftyJSON

enum APIError: Error {
    case decodeError
    case NullData
    case requestError(desc: String)
    case tokenInvalid
}

protocol APIBaseRequest {
    func sendRequest(medthod: HTTPMethod, url: URL, parameter: [String: Any]?, headers: [String: String]?) -> Single<JSON>
    func uploadFile(medthod: HTTPMethod, url: URL, data: Data, headers: [String: String]?) -> Single<JSON>
}

protocol APIRequest: APIBaseRequest, APIToken, CKLoginURL {
    func apiRequest(medthod: HTTPMethod, url: URL, parameter: [String: Any]?) -> Single<JSON>
    func apiUploadFile(medthod: HTTPMethod, url: URL, data: Data) -> Single<JSON>
}

protocol APIDataTransform {
    func dataDecoderTransform<T: Codable>(_ type:T.Type, _ value: JSON) -> T?
    func dataDecoderArrayTransform<T: Codable>(_ type:T.Type, _ value: [JSON]) -> [T]
}

protocol APIToken {
    func saveToken(_ token: String)
    func token() -> String?
    func clearToken()
}


extension APIBaseRequest {
    func sendRequest(medthod: HTTPMethod, url: URL, parameter: [String: Any]?, headers: HTTPHeaders?) -> Single<JSON> {
        return Single<JSON>.create { (single) -> Disposable in
            let _ = request(medthod, url, parameters: parameter, headers: headers)
                .json()
                .map({JSON($0)})
                .subscribe(onNext: { (item) in
                    single(.success(item))
                },onError: { (error) in
                    single(.error(APIError.requestError(desc: error.localizedDescription)))
                })
            return Disposables.create()
        }
    }
}

extension APIRequest {
    public func apiRequest(medthod: HTTPMethod, url: URL, parameter: [String: Any]?) -> Single<JSON> {
        return Single<JSON>.create { (single) -> Disposable in
            let headers = (url != self.loginURL) ? ["Token": self.token() ?? ""] : nil
            let _ = self.sendRequest(medthod: medthod, url: url, parameter: parameter, headers: headers)
                .subscribe(onSuccess: { (result) in
                    switch result["Code"].intValue {
                    case 400:
                        let errorMsg = result["Message"].string ?? ""
                        single(.error(APIError.requestError(desc: errorMsg)))
                    case 403:
                        single(.error(APIError.tokenInvalid))
                    default:
                        single(.success(result))
                        break
                    }
                }) { (error) in
                    single(.error(APIError.requestError(desc: error.localizedDescription)))
                }
            return Disposables.create()
        }
    }
    
    
    func apiUploadFile(medthod: HTTPMethod, url: URL, data: Data) -> Single<JSON> {
        let headers = (url != self.loginURL) ? ["Token": self.token() ?? ""] : nil
        return Single<JSON>.create { (single) -> Disposable in
            let _ = self.uploadFile(medthod: medthod, url: url, data: data, headers: headers)
                .subscribe(onSuccess: { (result) in
                    switch result["Code"].intValue {
                    case 400:
                        let errorMsg = result["Message"].string ?? ""
                        single(.error(APIError.requestError(desc: errorMsg)))
                    case 403:
                        single(.error(APIError.tokenInvalid))
                    default:
                        single(.success(result))
                        break
                    }
                }) { (error) in
                    single(.error(APIError.requestError(desc: error.localizedDescription)))
                }
            return Disposables.create()
        }
    }
}

extension APIDataTransform {
    func dataDecoderTransform<T: Codable>(_ type:T.Type, _ value: JSON) -> T? {
        do {
            //轉回 Data
            let dictData = try JSONSerialization.data(withJSONObject: value.dictionaryObject ?? [String: Any](), options: .prettyPrinted)
            //將 data 轉成 model
            let model = try JSONDecoder().decode(type.self, from: dictData)
            return model
        } catch {
            print("DataDecoderTransform Error : \(error)")
            return nil
        }
    }
    
    func dataDecoderArrayTransform<T: Codable>(_ type:T.Type, _ value: [JSON]) -> [T] {
        var models:[T] = []
        for json in value {
            do {
                let dictData = try JSONSerialization.data(withJSONObject: json.dictionaryObject ?? [String: Any](), options: .prettyPrinted)
                let model = try JSONDecoder().decode(type.self, from: dictData)
                models.append(model)
            } catch {
                print("DataDecoderArrayTransform Error : \(error)")
            }
        }
        return models
    }
}

extension APIToken {
    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "APIToken")
    }
    
    func token() -> String? {
        return UserDefaults.standard.value(forKey: "APIToken") as? String
    }
    
    func clearToken() {
        UserDefaults.standard.set(nil, forKey: "APIToken")
    }
}
