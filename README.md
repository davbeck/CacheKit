# CacheKit

[![CI Status](http://img.shields.io/travis/davbeck/CacheKit.svg?style=flat)](https://travis-ci.org/David Beck/CacheKit)
[![Version](https://img.shields.io/cocoapods/v/CacheKit.svg?style=flat)](http://cocoadocs.org/docsets/CacheKit)
[![License](https://img.shields.io/cocoapods/l/CacheKit.svg?style=flat)](http://cocoadocs.org/docsets/CacheKit)
[![Platform](https://img.shields.io/cocoapods/p/CacheKit.svg?style=flat)](http://cocoadocs.org/docsets/CacheKit)

## Usage

> To run the example project, clone the repo, and run `pod install` from the Example directory first.

You can access a cache similarly to NSMutableDictionary or NSCache:

```objective-c
[cache setObject:@1 forKey:@"A"];
[cache objectForKey:@"A"]; // returns @1 if it still exists
```

In addition, you can specify an expiration date:

```objective-c
[cache setObject:@1 forKey:@"A" expiresIn:30.0];
[cache objectForKey:@"A"]; // returns @1
// 31 seconds later...
[cache objectForKey:@"A"]; // returns nil
```

There are several reasons why `-objectForKey:` would return nil. The object could have expired, deleted in a 
background thread, or in the case of an in memory cache, the object could have been evicted during a memory 
warning. The best way to use an CKCache is to provide a content block in the case of a cache miss.

```objective-c
[cache objectForKey:@"A" withContent:^{
    return @1;
}]; // returns @1 if the object for @"A" doesn't exist or has expired
```

You can use shared caches if you just want to quickly throw data into something. Just make sure you use globally
unique keys. For instance, you could prefix keys with a class name.

```objective-c
[[CKSQLiteCache sharedCache] objectForKey:@"MyViewController.A" withContent:^{
    return @1;
}];
```

There are several different subclasses of `CKCache` for different purposes:

### CKMemoryCache

This is a wrapper around `NSCache`. It's objects are not persisted between launches.

### CKFileCache

This is a persistent cache that stores it's objects as files on disk. Use this cache if the objects you are 
storeing are extremely large. Each object is it's own file, encoded using `NSCoding` and stored in the caches
directory under the name of the cache and key. Make sure that the keys you use are valid file names and the 
objects conform to `NSCoding`.

The cache also has an internal `NSCache` for qucker access.

### CKSQLiteCache

This is a persistent cache that uses an SQLite database to store it's objects. The database is saved to the 
cache directory by the name of the cache. Each object is encoded using `NSCoding` and stored as a BLOB in 
the database. Make sure that the objects conform to `NSCoding`. Use this type of cache for most persistent 
caching. The only reason you might want to use `CKFileCache` instead is if your objects were very large.

[FMDB](https://github.com/ccgus/fmdb) is used internally for the interface to SQLite.

The cache also has an internal `NSCache` for qucker access.

### CKNullCache

A useless cache that doesn't store anything. Use this if you want to test your app without caching and you
want to quickly swap out another cache type. Make sure to provide fallback content blocks when fetching data
since the bare `-objectForKey:` will always return nil no matter what.

## Requirements

CacheKit requires iOS 6 or 10.8.

## Installation

CacheKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "CacheKit"

## License

CacheKit is available under the MIT license. See the LICENSE file for more info.

