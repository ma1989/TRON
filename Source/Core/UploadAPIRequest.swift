//
//  UploadAPIRequest.swift
//  TRON
//
//  Created by Denys Telezhkin on 11.09.16.
//  Copyright © 2015 - present MLSDev. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import Alamofire

public enum UploadRequestType {
    
    /// Will create `NSURLSessionUploadTask` using `uploadTaskWithRequest(_:fromFile:)` method
    case uploadFromFile(URL)
    
    /// Will create `NSURLSessionUploadTask` using `uploadTaskWithRequest(_:fromData:)` method
    case uploadData(Data)
    
    /// Will create `NSURLSessionUploadTask` using `uploadTaskWithStreamedRequest(_)` method
    case uploadStream(InputStream)
    
    // Depending on resulting size of the payload will either stream from disk or from memory
    case multipartFormData((MultipartFormData) -> Void)
}

/**
 `UploadAPIRequest` encapsulates upload request creation logic, stubbing options, and response/error parsing.
 */
open class UploadAPIRequest<Model, ErrorModel>: BaseRequest<Model,ErrorModel> {
    
    /// UploadAPIRequest type
    let type: UploadRequestType
    
    /// Serializes received response into Result<Model>
    open var responseParser : ResponseParser
    
    /// Serializes received error into APIError<ErrorModel>
    open var errorParser : ErrorParser
    
    // Creates `UploadAPIRequest` with specified `type`, `path` and configures it with to be used with `tron`.
    init<Serializer : ErrorHandlingDataResponseSerializerProtocol>(type: UploadRequestType, path: String, tron: TRON, responseSerializer: Serializer)
        where Serializer.SerializedObject == Model, Serializer.SerializedError == ErrorModel
    {
        self.type = type
        self.responseParser = { request,response, data, error in
            responseSerializer.serializeResponse(request,response,data,error)
        }
        self.errorParser = { result, request,response, data, error in
            return responseSerializer.serializeError(result,request, response, data, error)
        }
        super.init(path: path, tron: tron)
    }
    
    override func alamofireRequest(from manager: SessionManager) -> Request? {
        switch type {
        case .uploadFromFile(let url):
            return manager.upload(url, to: urlBuilder.url(forPath: path), method: method, headers: headerBuilder.headers(forAuthorizationRequirement: authorizationRequirement, including: headers))
            
        case .uploadData(let data):
            return manager.upload(data, to: urlBuilder.url(forPath: path), method: method, headers: headerBuilder.headers(forAuthorizationRequirement: authorizationRequirement, including: headers))
            
        case .uploadStream(let stream):
            return manager.upload(stream, to: urlBuilder.url(forPath: path), method: method, headers: headerBuilder.headers(forAuthorizationRequirement: authorizationRequirement, including: headers))
            
        case .multipartFormData(_):
            return nil
        }
    }
    
    /**
     Send current request.
     
     - parameter successBlock: Success block to be executed when request finished
     
     - parameter failureBlock: Failure block to be executed if request fails. Nil by default.
     
     - returns: Alamofire.Request or nil if request was stubbed.
     */
    @discardableResult
    open func perform(withSuccess successBlock: ((Model) -> Void)? = nil, failure failureBlock: ((APIError<ErrorModel>) -> Void)? = nil) -> UploadRequest?
    {
        if performStub(success: successBlock, failure: failureBlock) {
            return nil
        }
        return performAlamofireRequest {
            self.callSuccessFailureBlocks(successBlock, failure: failureBlock, response: $0)
        }
    }
    
    /**
     Perform current request with completion block, that contains Alamofire.Response.
     
     - parameter completion: Alamofire.Response completion block.
     
     - returns: Alamofire.Request or nil if request was stubbed.
     */
    @discardableResult
    open func performCollectingTimeline(withCompletion completion: @escaping ((Alamofire.DataResponse<Model>) -> Void)) -> UploadRequest? {
        if performStub(completion: completion) {
            return nil
        }
        return performAlamofireRequest(completion)
    }
    
    /**
     Perform multipart form data upload.
     
     - parameter success: Success block to be executed when request finished
     
     - parameter failure: Failure block to be executed if request fails. Nil by default.
     
     - parameter encodingMemoryThreshold: If data size is less than `encodingMemoryThreshold` request will be streamed from memory, otherwise - from disk.
     
     - parameter encodingCompletion: Encoding completion block, that can be used to inspect encoding result. No action is required by default,  default value for this block is nil.
     */
    open func performMultipart(withSuccess successBlock: @escaping (Model) -> Void, failure failureBlock: ((APIError<ErrorModel>) -> Void)? = nil, encodingMemoryThreshold: UInt64 = SessionManager.multipartFormDataEncodingMemoryThreshold, encodingCompletion: ((SessionManager.MultipartFormDataEncodingResult) -> Void)? = nil)
    {
        guard let manager = tronDelegate?.manager else {
            fatalError("Manager cannot be nil while performing APIRequest")
        }
        willSendRequest()
        guard case UploadRequestType.multipartFormData(let multipartFormDataBlock) = type else {
            return
        }
        
        if performStub(success: successBlock, failure: failureBlock) {
            return
        }
        
        let multipartConstructionBlock: (MultipartFormData) -> Void = { requestFormData in
            self.parameters.forEach { (key,value) in
                requestFormData.append(String(describing: value).data(using:.utf8) ?? Data(), withName: key)
            }
            multipartFormDataBlock(requestFormData)
        }
        
        let encodingCompletion: (SessionManager.MultipartFormDataEncodingResult) -> Void = { completion in
            if case .failure(let error) = completion {
                let apiError = APIError<ErrorModel>(request: nil, response: nil, data: nil, error: error)
                failureBlock?(apiError)
            } else if case .success(let request, _, _) = completion {
                self.willSendAlamofireRequest(request)
                _ = request.validate().response(queue : self.resultDeliveryQueue,
                                                responseSerializer: self.dataResponseSerializer(with: request))
                {
                    self.callSuccessFailureBlocks(successBlock, failure: failureBlock, response: $0)
                }
                if !(self.tronDelegate?.manager.startRequestsImmediately ?? false){
                    request.resume()
                }
                self.didSendAlamofireRequest(request)
                encodingCompletion?(completion)
            }
        }
        
        manager.upload(multipartFormData:  multipartConstructionBlock, usingThreshold: encodingMemoryThreshold,
                       to: urlBuilder.url(forPath: path),
                       method: method,
                       headers:  headerBuilder.headers(forAuthorizationRequirement: authorizationRequirement, including: headers),
                       encodingCompletion:  encodingCompletion)
    }
    
    private func performAlamofireRequest(_ completion : @escaping (DataResponse<Model>) -> Void) -> UploadRequest
    {
        guard let manager = tronDelegate?.manager else {
            fatalError("Manager cannot be nil while performing APIRequest")
        }
        willSendRequest()
        guard let request = alamofireRequest(from: manager) as? UploadRequest else {
            fatalError("Failed to receive UploadRequest")
        }
        willSendAlamofireRequest(request)
        if !tronDelegate!.manager.startRequestsImmediately {
            request.resume()
        }
        didSendAlamofireRequest(request)
        return request.validate().response(queue: resultDeliveryQueue,responseSerializer: dataResponseSerializer(with: request), completionHandler: { [weak self] dataResponse in
                self?.didReceiveDataResponse(dataResponse, forRequest: request)
                completion(dataResponse)
        })
    }
    
    internal func dataResponseSerializer(with request: Request) -> Alamofire.DataResponseSerializer<Model> {
        return DataResponseSerializer<Model> { [weak self] urlRequest, response, data, error in
            guard let weakSelf = self else {
                debugPrint("Request deallocated before calling DataResponseSerializer")
                return .failure(TRONError.requestDeallocated)
            }
            self?.willProcessResponse((urlRequest,response,data,error), for: request)
            var result : Alamofire.Result<Model>
            var apiError : APIError<ErrorModel>?
            var parsedModel : Model?
            
            if let error = error {
                apiError = weakSelf.errorParser(nil, urlRequest, response, data, error)
                result = .failure(apiError!)
            } else {
                result = weakSelf.responseParser(urlRequest, response, data, error)
                if let model = result.value {
                    parsedModel = model
                    result = .success(model)
                } else {
                    apiError = weakSelf.errorParser(result, urlRequest, response, data, error)
                    result = .failure(apiError!)
                }
            }
            if let error = apiError {
                self?.didReceiveError(error, for: (urlRequest,response,data,error), request: request)
            } else if let model = parsedModel {
                self?.didSuccessfullyParseResponse((urlRequest,response,data,error), creating: model, forRequest: request)
            }
            return result
        }
    }
}

@available(*,unavailable,renamed: "UploadAPIRequest")
class MultipartAPIRequest {}
