//
//  ASDKInitRequestBuilder.m
//  ASDKCore
//
// Copyright (c) 2016 TCS Bank
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "ASDKInitRequestBuilder.h"

@interface ASDKInitRequestBuilder ()

@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, copy) NSString *customerKey;
@property (nonatomic, copy) NSString *requestDescription;
@property (nonatomic, copy) NSString *payForm;
@property (nonatomic, copy) NSString *payType;
@property (nonatomic) BOOL recurrent;
@property (nonatomic, strong) NSString *additionalPaymentData;
@property (nonatomic, strong) NSDictionary *additionalPaymentData_;


@end

@implementation ASDKInitRequestBuilder

+ (ASDKInitRequestBuilder *)builderWithAmount:(NSNumber *)amount
                                      orderId:(NSString *)orderId
                                  description:(NSString *)description
                                      payForm:(NSString *)payForm
									  payType:(NSString *)payType
                                  customerKey:(NSString *)customerKey
                                    recurrent:(BOOL)recurrent
                                  terminalKey:(NSString *)terminalKey
                                     password:(NSString *)password
						additionalPaymentData:(NSDictionary *)data
{
    ASDKInitRequestBuilder *builder = [[ASDKInitRequestBuilder alloc] init];
    
    if (builder)
    {
        builder.amount = [NSNumber numberWithDouble:[NSString stringWithFormat:@"%.2f",amount.doubleValue].doubleValue];
        builder.orderId = orderId;
        builder.requestDescription = description;
		builder.payType = payType;
        builder.payForm = payForm;
        builder.customerKey = customerKey;
        builder.recurrent = recurrent;
        builder.terminalKey = terminalKey;
        builder.password = password;
		builder.additionalPaymentData_ = data;
		builder.additionalPaymentData = nil;
    }

    return builder;
}

- (ASDKAcquiringRequest *)buildError:(ASDKAcquringSdkError **)error
{
    ASDKAcquringSdkError *validationError;
    
    [self validateError:&validationError];
    
    if (validationError)
    {
        *error = validationError;
        
        return nil;
    }
    
    NSString *token = [self makeToken];
    
	ASDKInitRequest *request = [[ASDKInitRequest alloc] initWithTerminalKey:self.terminalKey
                                                                     amount:self.amount
                                                                    orderId:self.orderId
                                                                description:self.requestDescription
                                                                      token:token
                                                                    payForm:self.payForm
																	payType:self.payType
                                                                customerKey:self.customerKey
                                                                  recurrent:self.recurrent
													  additionalPaymentData:self.additionalPaymentData];

    return request;
}

- (void)validateError:(ASDKAcquringSdkError **)error
{
    ASDKAcquringSdkError *validationError;

//ОБЯЗАТЕЛЬНЫЕ ПОЛЯ
#define kASDKAmountDescription @"Сумма в копейках."
#define kASDKAmountMaxLength 10
    NSString *amount = [NSString stringWithFormat:@"%.0f",self.amount.doubleValue];
    if (amount.length > kASDKAmountMaxLength || self.amount.doubleValue <= 0)
    {
        validationError = [ASDKAcquringSdkError errorWithMessage:kASDKAmount details:[NSString stringWithFormat:@"%@ %@ %d",kASDKAmountDescription, kASDKValidationErrorMaxLengthString, kASDKAmountMaxLength] code:0];
        
        [(ASDKAcquringSdkError *)validationError setIsSdkError:NO];
        
        *error = validationError;
        
        return;
    }
    
#define kASDKOrderIdDescription @"Номер заказа в системе Продавца."
#define kASDKOrderIdMaxLength 50
    NSString *orderId = self.orderId;
    if (orderId.length > kASDKOrderIdMaxLength || orderId.length == 0)
    {
        validationError = [ASDKAcquringSdkError errorWithMessage:kASDKOrderId details:[NSString stringWithFormat:@"%@ %@ %d",kASDKOrderIdDescription, kASDKValidationErrorMaxLengthString, kASDKOrderIdMaxLength] code:0];
        
        [(ASDKAcquringSdkError *)validationError setIsSdkError:NO];
        
        *error = validationError;
        
        return;
    }
    
//ОПЦИОНАЛЬНЫЕ ПОЛЯ
#define kASDKDescriptionDescription @"Краткое описание."
#define kASDKDescriptionMaxLength 250
    NSString *requestDescription = self.requestDescription;
    if (requestDescription.length > kASDKDescriptionMaxLength)
    {
        validationError = [ASDKAcquringSdkError errorWithMessage:kASDKDescription details:[NSString stringWithFormat:@"%@ %@ %d",kASDKDescriptionDescription, kASDKValidationErrorMaxLengthString, kASDKDescriptionMaxLength] code:0];
        
        [(ASDKAcquringSdkError *)validationError setIsSdkError:NO];
        
        *error = validationError;
        
        return;
    }
    
#define kASDKPayFormDescription @"Название шаблона формы оплаты продавца."
#define kASDKPayFormMaxLength 20
    NSString *payForm = self.payForm;
    if (payForm.length > kASDKPayFormMaxLength)
    {
        validationError = [ASDKAcquringSdkError errorWithMessage:kASDKPayForm details:[NSString stringWithFormat:@"%@ %@ %d",kASDKPayFormDescription, kASDKValidationErrorMaxLengthString, kASDKPayFormMaxLength] code:0];
        
        [(ASDKAcquringSdkError *)validationError setIsSdkError:NO];
        
        *error = validationError;
        
        return;
    }
    
#define kASDKCustomerKeyDescription @"Идентификатор покупателя в системе Продавца. Если передается и Банком разрешена автоматическая привязка карт к терминалу, то для данного покупателя будет осуществлена привязка карты."
#define kASDKCustomerKeyMaxLength 36
    NSString *customerKey = self.customerKey;
    if (customerKey.length > kASDKCustomerKeyMaxLength)
    {
        validationError = [ASDKAcquringSdkError errorWithMessage:kASDKCustomerKey details:[NSString stringWithFormat:@"%@ %@ %d",kASDKCustomerKeyDescription, kASDKValidationErrorMaxLengthString, kASDKCustomerKeyMaxLength] code:0];
        
        [(ASDKAcquringSdkError *)validationError setIsSdkError:NO];
        
        *error = validationError;
        
        return;
    }
	
	if ([self.additionalPaymentData_ count] > 0)
	{
		if ([self.additionalPaymentData_ objectForKey:@"Email"] == nil && [self.additionalPaymentData_ objectForKey:@"email"] == nil)
		{
			validationError = [ASDKAcquringSdkError errorWithMessage:kASDKDATA details:@"Обязательным является наличие дополнительного параметра 'Email'" code:0];
			
			[(ASDKAcquringSdkError *)validationError setIsSdkError:NO];
			
			*error = validationError;
			
			return;
		}

		BOOL invalidAdditionalPaymentData = NO;
		if ([[self.additionalPaymentData_ allKeys] count] > 20)
		{
			invalidAdditionalPaymentData = YES;
		}
		else for (NSString *key in [self.additionalPaymentData_ allKeys])
		{
			if ([key length] > 20 || [[self.additionalPaymentData_ objectForKey:key] length] > 100)
			{
				invalidAdditionalPaymentData = YES;
				break;
			}
		}

		if (invalidAdditionalPaymentData == YES)
		{
			validationError = [ASDKAcquringSdkError errorWithMessage:kASDKDATA details:@"Ключ – 20 знаков, Значение – 100 знаков. Максимальное количество пар «ключ-значение» не может превышать 20." code:0];
			[(ASDKAcquringSdkError *)validationError setIsSdkError:NO];
			*error = validationError;
		}
	}
}

- (NSDictionary *)parametersForToken
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{kASDKTerminalKey : [self terminalKey],
                                                                                      kASDKPassword : [self password]}];
    if (self.amount)
    {
        [parameters setObject:self.amount.stringValue forKey:kASDKAmount];
    }
    if (self.orderId.length > 0)
    {
        [parameters setObject:self.orderId forKey:kASDKOrderId];
    }
    if (self.requestDescription.length > 0)
    {
        [parameters setObject:self.requestDescription forKey:kASDKDescription];
    }
    
    if (self.payForm.length > 0)
    {
        [parameters setObject:self.payForm forKey:kASDKPayForm];
    }

	if (self.payType.length > 0)
	{
		[parameters setObject:self.payType forKey:kASDKPayType];
	}

    if (self.customerKey.length > 0)
    {
        [parameters setObject:self.customerKey forKey:kASDKCustomerKey];
    }
    
    if (self.recurrent)
    {
        [parameters setObject:@"Y" forKey:kASDKRecurrent];
    }

	if ([self.additionalPaymentData_ count] > 0)
	{

		NSUInteger i = 0;
		NSUInteger count = [[self.additionalPaymentData_ allKeys] count] - 1;
		NSMutableString *strPostBody = [[NSMutableString alloc] init];
		for (NSString *key in [self.additionalPaymentData_ allKeys])
		{
			NSString *data = [NSString stringWithFormat:@"%@=%@%@", [self encodeURL:key], [self encodeURL:[[self.additionalPaymentData_ objectForKey:key] description]], (i < count ?  @"|" : @"")];
			[strPostBody appendString:data];
			i++;
		}
		
		self.additionalPaymentData = strPostBody;

		[parameters setObject:strPostBody forKey:kASDKDATA];
	}
	
	NSString *location = [[[NSLocale currentLocale] objectForKey:NSLocaleIdentifier] lowercaseString];
	if ([location rangeOfString:@"ru_"].location == NSNotFound)
	{
		[parameters setObject:@"en" forKey:@"Language"];
	}

    return parameters;
}

- (NSString *)encodeURL:(NSString *)string
{
//	NSMutableCharacterSet * characterSet = [NSMutableCharacterSet URLQueryAllowedCharacterSet];
//	NSString *newString = [string stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
	
	NSMutableCharacterSet * characterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"];
	[characterSet invert];
	NSString *newString = [string stringByAddingPercentEncodingWithAllowedCharacters:characterSet];

//	NSString *newString = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//																								(__bridge CFStringRef)string,
//																								NULL,
//																								(CFStringRef)@":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`",
//																								CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
	if (newString)
	{
		return newString;
	}
	
	return @"";
}

@end
