//
//  SSKeychain.m
//  SSKeychain
//
//  Created by Sam Soffes on 5/19/10.
//  Copyright (c) 2010-2014 Sam Soffes. All rights reserved.
//

#import "SSKeychain.h"

NSString *const kSSKeychainErrorDomain = @"yourdomain.sskeychain";
NSString *const kSSKeychainAccountKey = @"acct";
NSString *const kSSKeychainCreatedAtKey = @"cdat";
NSString *const kSSKeychainClassKey = @"labl";
NSString *const kSSKeychainDescriptionKey = @"desc";
NSString *const kSSKeychainLabelKey = @"labl";
NSString *const kSSKeychainLastModifiedKey = @"mdat";
NSString *const kSSKeychainWhereKey = @"svce";

#if __IPHONE_4_0 && TARGET_OS_IPHONE
	static CFTypeRef SSKeychainAccessibilityType = NULL;
#endif

@implementation SSKeychain

+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account {
	return [self passwordForService:serviceName account:account error:nil];
}


+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account error:(NSError *__autoreleasing *)error {
	SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
	query.service = serviceName;
	query.account = account;
	[query fetch:error];
	return query.password;
}


+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account {
	return [self deletePasswordForService:serviceName account:account error:nil];
}


+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account error:(NSError *__autoreleasing *)error {
	SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
	query.service = serviceName;
	query.account = account;
	return [query deleteItem:error];
}


+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account {
	return [self setPassword:password forService:serviceName account:account error:nil];
}


+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError *__autoreleasing *)error {
	SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
	query.service = serviceName;
	query.account = account;
	query.password = password;
	return [query save:error];
}

+ (NSString *)accountForService:(NSString *)serviceName {
    return [self accountForService:serviceName error:nil];
}


+ (NSString *)accountForService:(NSString *)serviceName error:(NSError *__autoreleasing *)error {
    NSString *foundAccount = nil;
    NSArray *accountList = [SSKeychain allAccounts];
    for( int i=0; i<accountList.count; i++ )
    {
        NSString *account = [[accountList objectAtIndex:i] objectForKey:@"acct"];
        NSString *password = [SSKeychain passwordForService:@"Expense" account:account];
        NSString *tempPassword = [NSString stringWithFormat:@"temp_password_for_only_account_%@", account];
        
        if( [password isEqualToString:tempPassword] )
        {
            foundAccount = account;
            break;
        }
    }
    
    return foundAccount;
}


+ (BOOL)deleteAccount:(NSString *)account serviceName:(NSString *)serviceName {
    return [self deleteAccount:account serviceName:serviceName error:nil];
}


+ (BOOL)deleteAccount:(NSString *)account serviceName:(NSString *)serviceName error:(NSError *__autoreleasing *)error {
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.account = account;
    query.service = serviceName;
    return [query deleteItem:error];
}


+ (BOOL)deleteAllAccountForService:(NSString *)serviceName
{
    return [self deleteAllAccountForService:serviceName error:nil];
}
+ (BOOL)deleteAllAccountForService:(NSString *)serviceName error:(NSError **)error
{
    NSArray *accountList = [SSKeychain accountsForService:serviceName];
    for( int i=0; i<accountList.count; i++ )
    {
        NSString *account = [[accountList objectAtIndex:i] objectForKey:@"acct"];
        BOOL result = [self deleteAccount:account serviceName:serviceName];
        if( result == NO )
            return NO;
    }
    
    return YES;
}


+ (BOOL)setAccount:(NSString *)account forService:(NSString *)serviceName {
    return [self setAccount:account forService:serviceName error:nil];
}


+ (BOOL)setAccount:(NSString *)account forService:(NSString *)serviceName error:(NSError *__autoreleasing *)error {
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    query.password = [NSString stringWithFormat:@"temp_password_for_only_account_%@", account];
    return [query save:error];
}


+ (NSArray *)allAccounts {
	return [self allAccounts:nil];
}


+ (NSArray *)allAccounts:(NSError *__autoreleasing *)error {
    return [self accountsForService:nil error:error];
}


+ (NSArray *)accountsForService:(NSString *)serviceName {
	return [self accountsForService:serviceName error:nil];
}


+ (NSArray *)accountsForService:(NSString *)serviceName error:(NSError *__autoreleasing *)error {
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    query.service = serviceName;
    return [query fetchAll:error];
}


#if __IPHONE_4_0 && TARGET_OS_IPHONE
+ (CFTypeRef)accessibilityType {
	return SSKeychainAccessibilityType;
}


+ (void)setAccessibilityType:(CFTypeRef)accessibilityType {
	CFRetain(accessibilityType);
	if (SSKeychainAccessibilityType) {
		CFRelease(SSKeychainAccessibilityType);
	}
	SSKeychainAccessibilityType = accessibilityType;
}
#endif

@end
