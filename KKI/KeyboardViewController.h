//
//  KeyboardViewController.h
//  KKI
//
//  Created by Rui on 13/11/2017.
//  Copyright © 2017 kathy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScrollViewWithButtons.h"
#import "GiphyCollectionViewCell.h"
#import <Giphy-iOS/AXCGiphy.h>
#import <SDWebImage/UIImageView+WebCache.h>

enum
{
    AlertStateNoSearchResults,
    AlertStateNoNetwork
};
typedef NSUInteger AlertState;

@interface KeyboardViewController : UIInputViewController
<UICollectionViewDataSource,
UICollectionViewDelegate,
ScrollViewWithButtonsDelegate>
//UISearchBarDelegate,
@property (weak, nonatomic) IBOutlet UICollectionView        *collectionView;
//@property (weak, nonatomic) IBOutlet UISearchBar             *searchBar;
@property (weak, nonatomic) IBOutlet ScrollViewWithButtons *giphyCategoriesScrollView;

@property (strong, nonatomic) NSArray                        *giphyResults;
@property (strong, nonatomic) NSString                       *sentURL;
@property (copy, nonatomic) NSString                         *searchedText;
@property (strong, nonatomic) NSArray                        *categoriesButtons;
@property (assign, nonatomic) NSInteger                      numberOfCells;

- (void)queryAXCGiphy:(NSString *)searchText;
- (void)cellUpToTop;
- (void)loadCells;
- (void)didAlertStates:(NSUInteger)status;
- (void)createCategoriesButtons;
- (void)highlightOffCategoriesButtons;
@end
