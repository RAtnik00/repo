#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <dlfcn.h>

static NSBundle *ZLBundle(void) {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Dl_info info = {0};
        if (dladdr((const void *)&ZLBundle, &info) && info.dli_fname) {
            NSString *dylibPath = [NSString stringWithUTF8String:info.dli_fname];
            NSString *bundlePath = [[dylibPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"ZoneLocalization.bundle"];
            bundle = [NSBundle bundleWithPath:bundlePath];
        }
    });
    return bundle;
}

static NSString *ZLTranslate(NSString *text) {
    if (![text isKindOfClass:NSString.class] || text.length == 0) return text;
    NSBundle *bundle = ZLBundle();
    if (!bundle) return text;
    NSString *translated = [bundle localizedStringForKey:text value:text table:@"Localizable"];
    if (![translated isEqualToString:text]) return translated;

    // The import button formats its count before assigning the title, so its
    // literal differs from the format key stored in the executable.
    if ([text hasPrefix:@"已导入"] && [text hasSuffix:@"张"]) {
        NSString *countText = [text substringWithRange:NSMakeRange(3, text.length - 4)];
        NSScanner *scanner = [NSScanner scannerWithString:countText];
        NSInteger count = 0;
        if ([scanner scanInteger:&count] && scanner.isAtEnd) {
            NSString *format = [bundle localizedStringForKey:@"已导入%ld张" value:nil table:@"Localizable"];
            if (![format isEqualToString:@"已导入%ld张"]) return [NSString stringWithFormat:format, (long)count];
        }
    }
    if ([text hasPrefix:@"已选中"]) {
        NSString *format = [bundle localizedStringForKey:@"已选中%@" value:nil table:@"Localizable"];
        if (![format isEqualToString:@"已选中%@"]) return [NSString stringWithFormat:format, [text substringFromIndex:3]];
    }
    if ([text hasPrefix:@"当前选中: "] && [text hasSuffix:@"]"]) {
        NSRange separator = [text rangeOfString:@" [" options:NSBackwardsSearch];
        if (separator.location != NSNotFound && separator.location > 5) {
            NSString *format = [bundle localizedStringForKey:@"当前选中: %@ [%@]" value:nil table:@"Localizable"];
            if (![format isEqualToString:@"当前选中: %@ [%@]"]) {
                NSString *first = [text substringWithRange:NSMakeRange(5, separator.location - 5)];
                NSString *second = [text substringWithRange:NSMakeRange(separator.location + 2, text.length - separator.location - 3)];
                return [NSString stringWithFormat:format, first, second];
            }
        }
    }
    NSArray<NSArray<NSString *> *> *prefixFormats = @[
        @[@"已替换(点击修改/恢复) ", @"已替换(点击修改/恢复) %@"],
        @[@"点击替换壁纸图片", @"点击替换壁纸图片%@"],
        @[@"成功插入: ", @"成功插入: %@"],
        @[@"当前选中图片: ", @"当前选中图片: %@"],
        @[@"图层已", @"图层已%@"]
    ];
    for (NSArray<NSString *> *pair in prefixFormats) {
        NSString *prefix = pair[0];
        if ([text hasPrefix:prefix] && text.length > prefix.length) {
            NSString *format = [bundle localizedStringForKey:pair[1] value:pair[1] table:@"Localizable"];
            if (![format isEqualToString:pair[1]]) return [NSString stringWithFormat:format, [text substringFromIndex:prefix.length]];
        }
    }
    if ([text hasPrefix:@"素材"]) {
        NSRange dot = [text rangeOfString:@"."];
        if (dot.location != NSNotFound && dot.location > 2) {
            NSString *number = [text substringWithRange:NSMakeRange(2, dot.location - 2)];
            NSScanner *scanner = [NSScanner scannerWithString:number];
            NSInteger index = 0;
            if ([scanner scanInteger:&index] && scanner.isAtEnd) {
                NSString *format = [bundle localizedStringForKey:@"素材%d.%@" value:nil table:@"Localizable"];
                if (![format isEqualToString:@"素材%d.%@"])
                    return [NSString stringWithFormat:format, (int)index, [text substringFromIndex:dot.location + 1]];
            }
        }
    }
    return text;
}

%hook UILabel
- (void)setText:(NSString *)text {
    text = ZLTranslate(text);
    %orig;
}
- (void)setAttributedText:(NSAttributedString *)text {
    if (text.length) {
        NSString *translated = ZLTranslate(text.string);
        if (![translated isEqualToString:text.string]) {
            NSDictionary *attributes = [text attributesAtIndex:0 effectiveRange:NULL] ?: @{};
            text = [[NSAttributedString alloc] initWithString:translated attributes:attributes];
        }
    }
    %orig;
}
%end

%hook UITextView
- (void)setText:(NSString *)text {
    text = ZLTranslate(text);
    %orig;
}
%end

%hook UIButton
- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    title = ZLTranslate(title);
    %orig;
}
%end

%hook UIBarButtonItem
- (void)setTitle:(NSString *)title {
    title = ZLTranslate(title);
    %orig;
}
%end

%hook UIAlertController
+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)style {
    title = ZLTranslate(title);
    message = ZLTranslate(message);
    return %orig;
}
- (void)setTitle:(NSString *)title {
    title = ZLTranslate(title);
    %orig;
}
- (void)setMessage:(NSString *)message {
    message = ZLTranslate(message);
    %orig;
}
%end

%hook UIAlertAction
+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction *))handler {
    title = ZLTranslate(title);
    return %orig;
}
%end

%hook UIAction
+ (instancetype)actionWithTitle:(NSString *)title image:(UIImage *)image identifier:(UIActionIdentifier)identifier handler:(UIActionHandler)handler {
    title = ZLTranslate(title);
    return %orig;
}
%end

%hook UIContextualAction
+ (instancetype)contextualActionWithStyle:(UIContextualActionStyle)style title:(NSString *)title handler:(UIContextualActionHandler)handler {
    title = ZLTranslate(title);
    return %orig;
}
%end
