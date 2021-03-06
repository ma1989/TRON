# Change Log
All notable changes to this project will be documented in this file.

# Next

## [4.0.0](https://github.com/MLSDev/TRON/releases/tag/4.0.0)

* Compiled with Xcode 9.1 / Swift 4.0.2

## [4.0.0-beta.2](https://github.com/MLSDev/TRON/releases/tag/4.0.0-beta.2)

* RxSwift dependency is bumped up to 4.0.0-beta.0, SwiftyJSON dependency is bumped to `4.0.0-alpha.1`
* Binary release is compiled with Xcode 9.0 Swift 4 compiler.
* Added ability to customize `JSONSerialization.ReadingOptions` for `JSONDecodableSerializer`. Unlike previous releases, no options are specified by default(Previously SwiftyJSON used `allowFragments` option).

To have old behavior that allows fragmented json, use:

```swift
let request = tron.swiftyJSON(readingOptions: .allowFragments).request("path")
```

* Added ability to customize `JSONDecoder` for `CodableSerializer` for both model parsing and error parsing.
* `CodableParser` and `JSONDecodableParser` are now classes, that are subclassible.

## [4.0.0-beta.1](https://github.com/MLSDev/TRON/releases/tag/4.0.0-beta.1)

**This is major release, containing breaking API changes, please read [TRON 4.0 Migration Guide](https://github.com/MLSDev/TRON/blob/master/Docs/4.0%20Migration%20Guide.md)**

* Implemented support for `Codable` protocol.
* `APIError` now takes it's localizedDescription from underlying `errorModel` if that model is `LocalizedError`, and from `error.localizedDescription` if not.

# Breaking changes

* `SwiftyJSONDecodable` methods are now prefixed with .swiftyJSON, like so:

```swift
// old
let request = tron.request("path")
// new
let request = tron.swiftyJSON.request("path")
```

## [3.1.1](https://github.com/MLSDev/TRON/releases/tag/3.1.1)

* Makes `NetworkActivityPlugin` always use API from the main thread(thanks, @mgurreta)!

## [3.1.0](https://github.com/MLSDev/TRON/releases/tag/3.1.0)

* Preliminary support for Swift 3.2 and Swift 4(Xcode 9 beta 6).

## [3.0.3](https://github.com/MLSDev/TRON/releases/tag/3.0.3)

* Prevent upload requests from being sent using `performMultipart` method if they are not of .multipartFormData type and vice versa, add specific assertions and error messages.
* Added `isMultipartRequest` property on `UploadRequestType`.

## [3.0.2](https://github.com/MLSDev/TRON/releases/tag/3.0.2)

* Improved SPM integration and CI scripts
* Added `validationClosure` properties on `APIRequest`, `DownloadAPIRequest` and `UploadAPIRequest` that allow customizing validation behaviour. Default behaviour, as before, is calling `validate()` method on `Request`.

## [3.0.1](https://github.com/MLSDev/TRON/releases/tag/3.0.1)

* Constructors on `APIRequest`, `UploadAPIRequest`, `APIStub` are made public to allow overriding in subclasses.

## [3.0.0](https://github.com/MLSDev/TRON/releases/tag/3.0.0)

### Breaking changes

* `dispatchQueue` property was removed from `Plugin` protocol. All `Plugin` events are now called synchronously to allow write access to objects, expecially requests. If `Plugin` requires any specific dispatch queue to run on, it must implement this logic itself.

### Bugfixes

* `APIStub` will now print error to console, if it failed to build model from file.
* `NetworkLoggerPlugin` will no longer double escape characters, when printing successful request cURL to console.

## [2.0.1](https://github.com/MLSDev/TRON/releases/tag/2.0.1)

Lowers deployment targets to iOS 8 / macOS 10.10

Required dependencies: Alamofire 4.1 and higher.

## [2.0.0](https://github.com/MLSDev/TRON/releases/tag/2.0.0)

* `NetworkLoggerPlugin` now has `logCancelledRequests` property, that allows turning off logging of failing requests, that were explicitly cancelled by developer.
* Ensures, that `APIStub` always calls completion blocks, even if response is not successfully created.

## [2.0.0-beta.5](https://github.com/MLSDev/TRON/releases/tag/2.0.0-beta.5)

* `APIStub` creation is deferred until `apiStub` property is called.
* `APIStub` `model` and `error` properties have been replaced with `modelClosure` and `errorClosure`, that are created in `APIStub` constructor. This is done to allow `APIStub` to function even if `APIRequest` has been deallocated.

## [2.0.0-beta.4](https://github.com/MLSDev/TRON/releases/tag/2.0.0-beta.4)

* Plugin protocol was rewritten to contain generic methods and more information about what is happening in TRON ecosystem.
* `ErrorHandlingDataResponseSerializerProtocol` and `ErrorHandlingDownloadResponseSerializerProtocol` now have protocol extensions for default SwiftyJSON error parsing.

## [2.0.0-beta.3](https://github.com/MLSDev/TRON/releases/tag/2.0.0-beta.3)

* `Parseable` protocol was rewritten to directly inherit from `Alamofire.DataResponseSerializerProtocol`. It allows us to have two generic typealiases - `SerializedObject` from `Alamofire` and added to it `SerializedError` from TRON.
* Fixed issue, that could cause completion handlers to be called on background thread.
* Use SwiftyJSON instead of forked SwiftyJSON3
* `parameters` property on `BaseRequest` now contains [String:Any] instead of [String:AnyObject]
* `processingQueue` property on `APIRequest` was removed.

## [2.0.0-beta.2](https://github.com/MLSDev/TRON/releases/tag/2.0.0-beta.2)

* Rewrite `Parseable` protocol using associatedtype.

## [2.0.0-beta.1](https://github.com/MLSDev/TRON/releases/tag/2.0.0-beta.1)

`TRON` 2.0 is supported on iOS 9.0, macOS 10.11 and higher due to Alamofire.framework required versions. Read [migration guide](/Docs/2.0 Migration Guide.md) for overview of API changes.

**NOTE** This release uses [forked SwiftyJSON](https://github.com/MLSDev/SwiftyJSON), and `SwiftyJSON3` cocoapod, because original repo has not been updated to Swift 3. In future release we hope to use `SwiftyJSON` cocoapod. [Link](https://github.com/SwiftyJSON/SwiftyJSON/issues/627#issuecomment-247761400)

### API changes

* `ResponseParseable` was rewritten and renamed to `Parseable`. It now allows creating models without using a constructor. Therefore, it's now possibly to use really any kind of mapper and make factory-like response builders.
* Success blocks on `APIRequest` are now optional and equal to nil by default.
* `MultipartAPIRequest` now becomes a part of larger `UploadAPIRequest` class.
* Introduced new `DownloadAPIRequest` class, that receives part of `APIRequest` functionality.

### Renamings

* Swift 3 API design guidelines have been applied to all API.
* `perform(completion:)` method was renamed to `performCollectingTimeline(withCompletion:)` to better match method internal behaviour
* `encoding` property on `TRON` and requests has been renamed to `parameterEncoding` and now has a different type - `Alamofire.ParameterEncoding`

### Removals

* `responseBuilder` property on `APIRequest` was removed, as it's no longer used when parsing received response.
* `JSONDecodable` extension on `Array` is temporarily unavailable due to issues with Swift compiler.
* `encodingStrategy` property on TRON was removed - please use `parameterEncoding` instead.
* `TRON.RESTencodingStrategy` and `TRON.URLEncodingStrategy` were removed - please refer to Alamofire 4 migration guide for details.
* `RequestType` enum was replaced by `UploadRequestType` and `DownloadRequestType` on `DownloadAPIRequest` and `UploadAPIRequest` classes.

## [1.1.1](https://github.com/MLSDev/TRON/releases/tag/1.1.1)

### Added

* Optional `progressClosure` parameter to `rxMultipartUpload` method for multipart requests

## [1.1.0](https://github.com/MLSDev/TRON/releases/tag/1.1.0)

### Added

* `stubbingShouldBeSuccessful` property on `TRON`, that allows setting up globally, will stubs succeed or not.
* `encodingStrategy` property on `TRON` instance, that is used to select encoding type based on HTTP Method.
* `encodingStrategy` property on `APIRequest`, that will be filled with `TRON` strategy on construction.

By default, for backwards compatibility reasons, we use ParameterEncoding.URL as a default strategy. This will change in next major release of TRON, which will use `TRON.RESTEncodingStrategy` instead. This encoding strategy uses .JSON encoding for POST, PUT and PATCH requests, and .URL encoding for all other HTTP methods.

### Deprecated

* `encoding` property on `APIRequest`. Please use `encodingStrategy` property instead.

## [1.0.0](https://github.com/MLSDev/TRON/releases/tag/1.0.0)

### Changes

None.

If you haven't been following beta releases, please read [1.0.0 Migration Guide](/Docs/1.0 Migration Guide.md) to get an overview of new API additions and phylosophy behind some breaking changes that were made in this release.

## [1.0.0-beta.3](https://github.com/MLSDev/TRON/releases/tag/1.0.0-beta.3)

### Breaking changes

* `ResponseParseable` protocol reworked to only include single initializer instead of associated type `ModelType`. Therefore, all generic methods that previously accepted `Model.ModelType` type now accept `Model` type.
* Removed `performWithSuccess(_:failure:)` method, please use `perform(success:failure:)` method instead.

### Added

* Ability to create APIRequest with Array generic constraint, for example - `APIRequest<[Int],TronError>`

### Changed

* `ResponseParseable` `initWithData:` method is now throwable, allowing parsed models to throw during initialization. When initializer throws, `APIRequest` treats it as a parsing error.

## [1.0.0-beta.2](https://github.com/MLSDev/TRON/releases/tag/1.0.0-beta.2)

### Breaking changes

* `ResponseParseable` protocol now accepts NSData instead of `AnyObject` in its constructor, allowing any kind of parsing, JSON/XML, you-name-it.

## [1.0.0-beta.1](https://github.com/MLSDev/TRON/releases/tag/1.0.0-beta.1)

TRON 1.0 is a major release with a lot of new features and breaking changes. To find out more about philosophy of those and how to adapt to new API's, read [TRON 1.0 Migration Guide](/Docs/1.0 Migration Guide.md)

### Breaking changes

* `RequestToken` protocol removed, perform request methods now return `Alamofire.Request?` to allow customization. When request is stubbed, nil is returned.
* `tron.multipartRequest(path:)` removed, use `tron.uploadMultipart(path:formData:)` method instead
* `MultipartAPIRequest` `performWithSuccess(_:failure:progress:cancellableCallback:)` method is replaced by `performMultipart(success:failure:encodingMemoryThreshold:encodingCompletion:)`
* `MultipartAPIRequest` no longer subclasses `APIRequest` - they both now subclass `BaseRequest`.
* `appendMultipartData(_:name:filename:mimeType:)` on `MultipartAPIRequest` is removed. Please use `Alamofire.Manager.MultipartFormData` built-in methods to append multipart data
* RxSwift extension on `MultipartAPIRequest` reworked to return single Observable<ModelType>
* `EventDispatcher` class and corresponding `TRON.dispatcher`, `APIRequest.dispatcher` property are replaced by `TRON` and `APIRequest` properties - `processingQueue` and `resultDeliveryQueue`, which are used to determine on which queue should processing be performed and on which queue results should be delivered.
* `Progress` and `ProgressClosure` typealiases have been removed

### Added

* `upload(path:file:)` - upload from file
* `upload(path:data:)` - upload data
* `upload(path:stream:)` - upload from stream
* `download(path:destination:)` - download file to destination
* `download(path:destination:resumingFromData:)` - download file to destination, resuming from data
* `uploadMultipart(path:formData:)` - multipart form data upload
* `perform(completion:)` method, that accepts `Alamofire.Response` -> Void block.

### Deprecations

* `APIRequest` `performWithSuccess(_:failure:)` method is deprecated, new name - `perform(success:failure:)`

## [0.4.3](https://github.com/MLSDev/TRON/releases/tag/0.4.3)

### Fixed

* Allow `MultipartAPIRequest` to use any StringLiteralConvertible value in parameters (for example Int, or Bool e.t.c).

## [0.4.2](https://github.com/MLSDev/TRON/releases/tag/0.4.2)

### Fixed

* Prevent `APIRequest` from being deallocated if rxResult Observable is passed elsewhere without keeping strong reference to `APIRequest` itself.

## [0.4.1](https://github.com/MLSDev/TRON/releases/tag/0.4.1)

### Fixed

* Plugins are now correctly notified with "willSendRequest(_:)" method call for multipart requests.

## [0.4.0](https://github.com/MLSDev/TRON/releases/tag/0.4.0)

### Breaking

* Update to Swift 2.2. This release is not backwards compatible with Swift 2.1.
* `NetworkActivityPlugin` now accepts `UIApplication` in it's initializer to be able to compile in application extensions environments.
* `NetworkActivityPlugin` supports only single instance of `TRON`. If you have multiple `TRON`s in your application, consider building another plugin, that uses static variables to track number of requests, similar to old `NetworkActivityPlugin` from `5639b960e968586d1e24a7adcc6a3420e8648d49`.

### Added

* Added `EmptyResponse` class that can be used for requests with empty body. For example:

```swift
let request : APIRequest<EmptyResponse, MyError> = tron.request("empty/response")
```

* RxSwift extensions for `APIRequest` and `MultipartAPIRequest`, usage:

```swift
let request : APIRequest<Foo, MyError> = tron.request("foo")
_ = request.rxResult.subscribeNext { result in
    print(result)
}
```

```swift
let multipartRequest = MultipartAPIRequest<Foo,MyError> = tron.multipartRequest("foo")

let (progress, result) = multipartRequest.rxUpload()

_ = progress.subscribeNext { progress in
    print(progress.bytesSent,progress.totalBytesWritten,progress.totalBytesExpectedToWrite)
}

_ = result.subscribeNext { result in
    print("Received result: \(result)")
}
```

## [0.3.0](https://github.com/MLSDev/TRON/releases/tag/0.3.0)

Completion blocks are now handled by new `EventDispatcher` class, which is responsible for running completion blocks on predefined GCD-queue.

Default behaviour - all parsing is made on QOS_CLASS_USER_INITIATED queue, success and failure blocks are called on main queue.

You can specify `processingQueue`, `successDeliveryQueue` and `failureDeliveryQueue` on `dispatcher` property of TRON. After request creation you can modify queues using `dispatcher` property on APIRequest, or even replace EventDispatcher with a custom one.

## [0.2.1](https://github.com/MLSDev/TRON/releases/tag/0.2.1)

Added public initializer for NetworkActivityPlugin

## [0.2.0](https://github.com/MLSDev/TRON/releases/tag/0.2.0)

Add support for any custom mapper to be used with TRON. Defaulting to `SwiftyJSON`.

Examples:

[Argo](https://github.com/MLSDev/TRON/blob/master/Custom%20mappers/Argo.playground/Contents.swift), [ObjectMapper](https://github.com/MLSDev/TRON/blob/support_custom_mappers/Custom%20mappers/ObjectMapper.playground/Contents.swift)

### Limitations

`ResponseParseable` and `JSONDecodable` are now Self-requirement protocols with all their limitations. Apart from that, there are some other limitations as well:

#### Subclasses

Subclassing ResponseParseable requires explicit typealias in subclassed model:

```swift
class Ancestor: JSONDecodable {
    required init(json: JSON) {

    }
}

class Sibling: Ancestor {
    typealias ModelType = Sibling
}
```

[Discussion in mailing Swift mailing lists](https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20151228/004645.html)

#### Multiple custom mappers

Current architecture does not support having more than one mapper in your project, because Swift is unable to differentiate between two ResponseParseable extensions on different types.

#### Arrays and CollectionTypes

Currently, there's no way to extend CollectionType or Array with `JSONDecodable` or `ResponseParseable` protocol, so creating request with ModelType of array(APIRequest<[Foo],Bar>) is not possible.

Blocking radars:
http://www.openradar.me/23433955
http://www.openradar.me/23196859

## [0.1.0](https://github.com/MLSDev/TRON/releases/tag/0.1.0)

Initial OSS release, yaaaay!
