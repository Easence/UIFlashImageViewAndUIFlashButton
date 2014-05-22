//
//  ViewController.m
//  flash
//
//  Created by ZhangWei on 14-5-4.
//  Copyright (c) 2014年 ZhangWei. All rights reserved.
//

#import "ViewController.h"
#import "UIFlashButton.h"
#import "UIFlashImageView.h"

@interface ViewController ()
{
    UIFlashImageView * upImageview;
    UIImageView * downImageview;
    BOOL          bAdding;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    UIImage* pTemp1 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"message-notification-off.png" ofType:nil]];
    
    UIImage* pTemp2 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"message-notification-glow_b.png" ofType:nil]];
    
    pTemp1 = [self toGrayscale:pTemp1];
    
    upImageview = [[UIFlashImageView alloc] initWithFrame:CGRectMake(0, 0, pTemp1.size.width/2, pTemp1.size.height/2)];
    [upImageview setImage:pTemp1];
    downImageview = [[UIImageView alloc] initWithFrame:upImageview.bounds];
    [downImageview setImage:pTemp2];
    downImageview.alpha = 0.3;
    
    upImageview.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    downImageview.center = upImageview.center;
    
//    [self.view addSubview:downImageview];
//    [self.view addSubview:upImageview];
    
    bAdding = YES;
    
    [NSTimer scheduledTimerWithTimeInterval:.05 target:self selector:@selector(changeAlphaValue) userInfo:nil repeats:YES];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIFlashButton *btnFlash = [[UIFlashButton alloc]initWithFrame:CGRectMake(20, 20, pTemp1.size.width/2, pTemp1.size.height/2)];
    [btnFlash setImage:pTemp1 forState:UIControlStateNormal];
    CGFloat offset = -20;
    btnFlash.flashEdgeInsets = UIEdgeInsetsMake(offset, offset, offset, offset);
    [btnFlash startFlashWithImage:pTemp2];
    
    [btnFlash addTarget:self action:@selector(actionButton:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:btnFlash];
    
    upImageview.flashEdgeInsets = UIEdgeInsetsMake(offset, offset, offset, offset);
    [upImageview startFlashWithImage:pTemp2];
    [self.view addSubview:upImageview];
    
}

- (void)actionButton:(id)sender
{
    UIFlashButton *btn = (UIFlashButton*)sender;
    if(btn.isFlashing)
        [btn stopFlash];
    else
        [btn startFlashAnimation];
    
    if(upImageview.isFlashing)
    {
        [upImageview stopFlash];
    }
    else
    {
        [upImageview startFlashAnimation];
    }
}

- (void)changeAlphaValue
{
    CGFloat fAlpha = downImageview.alpha;
    if (bAdding)
    {
        fAlpha = fAlpha + 0.05;
        if (fAlpha > 1)
        {
            bAdding = NO;
            fAlpha = 1;
        }
    }
    else
    {
        fAlpha = fAlpha - 0.05;
        if (fAlpha < 0.2)
        {
            bAdding = YES;
            fAlpha = 0.2;
        }
    }
    downImageview.alpha = fAlpha;
}

- (UIImage *)convertImageToGrayScale:(UIImage *)image
{
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGBitmapByteOrderDefault);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;
}

// Transform the image in grayscale.
- (UIImage*) grayishImage: (UIImage*) inputImage {
    
    // Create a graphic context.
    UIGraphicsBeginImageContextWithOptions(inputImage.size, YES, 1.0);
    CGRect imageRect = CGRectMake(0, 0, inputImage.size.width, inputImage.size.height);
    
    // Draw the image with the luminosity blend mode.
    // On top of a white background, this will give a black and white image.
    [inputImage drawInRect:imageRect blendMode:kCGBlendModeLuminosity alpha:1.0];
    
    // Get the resulting image.
    UIImage *filteredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return filteredImage;
    
}

#define ROUND_UP(N, S) ((((N) + (S) - 1) / (S)) * (S))

- (CGImageRef) createMaskWithImageAlpha: (UIImage*) originalImage {
    
    // Original RGBA image
    CGImageRef originalMaskImage = originalImage.CGImage;
    
    float width = CGImageGetWidth(originalMaskImage);
    float height = CGImageGetHeight(originalMaskImage);
    
    // Make a bitmap context that's only 1 alpha channel
    // WARNING: the bytes per row probably needs to be a multiple of 4
    int strideLength = ROUND_UP(width * 1, 4);
    unsigned char * alphaData = calloc(strideLength * height, sizeof(unsigned char));
    CGContextRef alphaOnlyContext = CGBitmapContextCreate(alphaData,
                                                          width,
                                                          height,
                                                          8,
                                                          strideLength,
                                                          NULL,
                                                          kCGBitmapByteOrderDefault);
    
    // Draw the RGBA image into the alpha-only context.
    CGContextDrawImage(alphaOnlyContext, CGRectMake(0, 0, width, height), originalMaskImage);
    
    // Walk the pixels and invert the alpha value. This lets you colorize the opaque shapes in the original image.
    // If you want to do a traditional mask (where the opaque values block) just get rid of these loops.
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            unsigned char val = alphaData[y*strideLength + x];
            val = 255 - val;
            alphaData[y*strideLength + x] = val;
        }
    }
    
    CGImageRef alphaMaskImage = CGBitmapContextCreateImage(alphaOnlyContext);
    CGContextRelease(alphaOnlyContext);
    free(alphaData);
    
    // Make a mask
    CGImageRef finalMaskImage = CGImageMaskCreate(CGImageGetWidth(alphaMaskImage),
                                                  CGImageGetHeight(alphaMaskImage),
                                                  CGImageGetBitsPerComponent(alphaMaskImage),
                                                  CGImageGetBitsPerPixel(alphaMaskImage),
                                                  CGImageGetBytesPerRow(alphaMaskImage),
                                                  CGImageGetDataProvider(alphaMaskImage), NULL, false);
    CGImageRelease(alphaMaskImage);
    
    return finalMaskImage;
}

- (UIImage *) toGrayscale : (UIImage*) originalImage
{
    const int RED = 1;
    const int GREEN = 2;
    const int BLUE = 3;
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, originalImage.size.width * originalImage.scale, originalImage.size.height * originalImage.scale);
    
    int width = imageRect.size.width;
    int height = imageRect.size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [originalImage CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
            
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                                 scale:originalImage.scale
                                           orientation:UIImageOrientationUp];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
