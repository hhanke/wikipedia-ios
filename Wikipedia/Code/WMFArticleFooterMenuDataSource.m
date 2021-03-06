#import "WMFArticleFooterMenuDataSource.h"
#import "WMFArticleFooterMenuItem.h"
#import "MWKArticle.h"
#import "NSDate+Utilities.h"
#import "WMFArticleFooterMenuCell.h"
#import "MWKTitle.h"

@interface WMFArticleFooterMenuDataSource ()

@property (nonatomic, strong, readwrite) MWKArticle* article;

@end

@implementation WMFArticleFooterMenuDataSource

- (instancetype)initWithArticle:(MWKArticle*)article {
    self = [super initWithItems:[self menuItemsForArticle:article]];
    if (self) {
        self.article            = article;
        self.cellClass          = [WMFArticleFooterMenuCell class];
        self.cellConfigureBlock = ^(WMFArticleFooterMenuCell* cell, WMFArticleFooterMenuItem* menuItem, UITableView* tableView, NSIndexPath* indexPath) {
            cell.title     = menuItem.title;
            cell.subTitle  = menuItem.subTitle;
            cell.imageName = menuItem.imageName;
        };

        self.tableActionBlock = ^BOOL (SSCellActionType action, UITableView* tableView, NSIndexPath* indexPath) {
            return NO;
        };
    }
    return self;
}

- (NSArray<WMFArticleFooterMenuItem*>*)menuItemsForArticle:(MWKArticle*)article {
    WMFArticleFooterMenuItem* (^ makeItem)(WMFArticleFooterMenuItemType, NSString*, NSString*, NSString*) = ^WMFArticleFooterMenuItem*(WMFArticleFooterMenuItemType type, NSString* title, NSString* subTitle, NSString* imageName) {
        return [[WMFArticleFooterMenuItem alloc] initWithType:type
                                                        title:title
                                                     subTitle:subTitle
                                                    imageName:imageName];
    };

    NSMutableArray* menuItems = [NSMutableArray new];

    if (article.languagecount > 0) {
        [menuItems addObject:makeItem(WMFArticleFooterMenuItemTypeLanguages,
                                      [MWSiteLocalizedString(article.title.site, @"page-read-in-other-languages", nil) stringByReplacingOccurrencesOfString:@"$1" withString:[NSString stringWithFormat:@"%d", article.languagecount]],
                                      nil, @"footer-switch-language")];
    }

    [menuItems addObject:makeItem(WMFArticleFooterMenuItemTypeLastEdited,
                                  [MWSiteLocalizedString(article.title.site, @"page-last-edited", nil) stringByReplacingOccurrencesOfString:@"$1" withString:[NSString stringWithFormat:@"%ld", [[NSDate date] daysAfterDate:article.lastmodified]]],
                                  MWSiteLocalizedString(article.title.site, @"page-edit-history", nil),
                                  @"footer-edit-history")];

    if (article.pageIssues.count > 0) {
        [menuItems addObject:makeItem(WMFArticleFooterMenuItemTypePageIssues,
                                      MWSiteLocalizedString(article.title.site, @"page-issues", nil),
                                      nil,
                                      @"footer-warnings")];
    }

    if (article.disambiguationTitles.count > 0) {
        [menuItems addObject:makeItem(WMFArticleFooterMenuItemTypeDisambiguation,
                                      MWSiteLocalizedString(article.title.site, @"page-similar-titles", nil),
                                      nil,
                                      @"footer-similar-pages")];
    }

    return menuItems;
}

@end
