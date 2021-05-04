#import "RCTCustomCropManager.h"
#import <React/RCTLog.h>

@implementation RCTCustomCropManager

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(crop:(NSDictionary *)points imageUri:(NSString *)imageUri callback:(RCTResponseSenderBlock)callback)
{
    NSString *parsedImageUri = [imageUri stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    NSURL *fileURL = [NSURL fileURLWithPath:parsedImageUri];

    CGPoint newLeft = CGPointMake([points[@"topLeft"][@"x"] floatValue], [points[@"topLeft"][@"y"] floatValue]);
    CGPoint newRight = CGPointMake([points[@"topRight"][@"x"] floatValue], [points[@"topRight"][@"y"] floatValue]);
    CGPoint newBottomLeft = CGPointMake([points[@"bottomLeft"][@"x"] floatValue], [points[@"bottomLeft"][@"y"] floatValue]);
    CGPoint newBottomRight = CGPointMake([points[@"bottomRight"][@"x"] floatValue], [points[@"bottomRight"][@"y"] floatValue]);

    newLeft = [self cartesianForPoint:newLeft height:[points[@"height"] floatValue] ];
    newRight = [self cartesianForPoint:newRight height:[points[@"height"] floatValue] ];
    newBottomLeft = [self cartesianForPoint:newBottomLeft height:[points[@"height"] floatValue] ];
    newBottomRight = [self cartesianForPoint:newBottomRight height:[points[@"height"] floatValue] ];

    
    NSMutableDictionary *rectangleCoordinates = [[NSMutableDictionary alloc] init];

    rectangleCoordinates[@"inputTopLeft"] = [CIVector vectorWithCGPoint:newLeft];
    rectangleCoordinates[@"inputTopRight"] = [CIVector vectorWithCGPoint:newRight];
    rectangleCoordinates[@"inputBottomLeft"] = [CIVector vectorWithCGPoint:newBottomLeft];
    rectangleCoordinates[@"inputBottomRight"] = [CIVector vectorWithCGPoint:newBottomRight];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CIImage *ciImage = [CIImage imageWithContentsOfURL:fileURL];
        ciImage = [ciImage imageByApplyingFilter:@"CIPerspectiveCorrection" withInputParameters:rectangleCoordinates];
        UIImage *image = [[UIImage alloc] initWithCIImage:ciImage];

        NSData *imageToEncode = UIImageJPEGRepresentation(image, 0.8);
        callback(@[[NSNull null], @{@"image": [imageToEncode base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]}]);
    });
}

- (CGPoint)cartesianForPoint:(CGPoint)point height:(float)height {
    return CGPointMake(point.x, height - point.y);
}

@end

