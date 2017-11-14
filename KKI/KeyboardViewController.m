//
//  KeyboardViewController.m
//  KKI
//
//  Created by Rui on 13/11/2017.
//  Copyright © 2017 kathy. All rights reserved.
//

#import "KeyboardViewController.h"

@import MobileCoreServices;

#define kGiphyCollectionCellDefaultColor  [UIColor clearColor]
#define kGiphyCollectionCellSelectedColor  [UIColor magentaColor]

NSString *const kCollectionViewCellIdentifier = @"cellReuseIdentifier";
NSInteger const kGiphySearchNumbers = 50;

@interface KeyboardViewController ()
//@property (nonatomic, strong) UIButton *nextKeyboardButton;
@end

@implementation KeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    // Add custom view sizing constraints here
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    [AXCGiphy setGiphyAPIKey:kGiphyPublicAPIKey];
    self.numberOfCells = kGiphySearchNumbers;
    
    // Set a default keyword for quering Giphy API
    self.searchedText = @"Sorry";
    [self queryAXCGiphy:self.searchedText];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    [self createCategoriesButtons];
//    [self.collectionView setHidden:true];
    // Perform custom UI setup here
//    self.nextKeyboardButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    
//    [self.nextKeyboardButton setTitle:NSLocalizedString(@"Next Keyboard", @"Title for 'Next Keyboard' button") forState:UIControlStateNormal];
//    [self.nextKeyboardButton sizeToFit];
//    self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    [self.nextKeyboardButton addTarget:self action:@selector(handleInputModeListFromView:withEvent:) forControlEvents:UIControlEventAllTouchEvents];
//    
//    [self.view addSubview:self.nextKeyboardButton];
//    
//    [self.nextKeyboardButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
//    [self.nextKeyboardButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
}

#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.giphyResults.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /*----------------------------------------------------------------------------*
     * Giphy collection view.
     *----------------------------------------------------------------------------*/
    GiphyCollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellIdentifier forIndexPath:indexPath];
    
    cell.giphyImageView.image = nil;
    
    // Set a colour of a selected cell
    cell.selectedBackgroundView = nil;
    if (cell.selected)
    {
        cell.backgroundColor = kGiphyCollectionCellSelectedColor;
    }
    else
    {
        cell.backgroundColor = kGiphyCollectionCellDefaultColor;
    }
    
    AXCGiphy *gif = self.giphyResults[indexPath.item];
    
    [cell startActiveIndicator];
    
    // Download a gif
    //    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    //    [manager loadImageWithURL:gif.fixedHeightDownsampledImage.url
    //                          options:SDWebImageRetryFailed
    //                         progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL *imageURL) {
    //                         }
    //                        completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
    //                            if (image)
    //                            {
    //                                cell.giphyImageView.image = image;
    //                                [cell stopActiveIndicator];
    //                            }
    //                        }];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:gif.originalImage.url];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        UIImage * image = [UIImage imageWithData:data];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            cell.giphyImageView.image = image;
        }];
    }] resume];
    
    // Load cells more
    if(indexPath.row == self.numberOfCells - 1)
        [self loadCells];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AXCGiphy *gif = self.giphyResults[indexPath.item];
    NSData *data = [NSData dataWithContentsOfURL:gif.originalImage.url];
    UIPasteboard *pasteBoard=[UIPasteboard generalPasteboard];
    [pasteBoard setData:data forPasteboardType:(__bridge NSString *)kUTTypeGIF];
    NSLog(@"imageUrl:%@", gif.originalImage.url);
//    [pasteBoard setURL:gif.originalImage.url];
}
-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    GiphyCollectionViewCell *cell = (GiphyCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = kGiphyCollectionCellSelectedColor;
    
    AXCGiphy *gif = self.giphyResults[indexPath.item];
    self.sentURL = [gif.originalImage.mp4 absoluteString];
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GiphyCollectionViewCell *cell = (GiphyCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = kGiphyCollectionCellDefaultColor; // Default color
}

#pragma mark - AXCGiphy

- (void)queryAXCGiphy:(NSString *)searchText
{
    [AXCGiphy searchGiphyWithTerm:searchText
                            limit:self.numberOfCells
                           offset:0
                       completion:^(NSArray *results, NSError *error)
     {
         self.giphyResults = results;
         
         if (self.giphyResults)
         {
             [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                 [self.collectionView reloadData];
                 [self cellUpToTop];
             }];
         }
     }];
}

- (void)cellUpToTop
{
    // Move cells to the top
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    [self.view layoutIfNeeded];
}

- (void)loadCells
{
    self.numberOfCells += 20;
    [self queryAXCGiphy:self.searchedText];
}

#pragma mark - GiphyScrollView Delegate

- (void)buttonInScrollViewTapped:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSString *categories = button.titleLabel.text;
    
    [self highlightOffCategoriesButtons];
    button.backgroundColor = [UIColor yellowColor];
    self.searchedText = categories;
    [self queryAXCGiphy:categories];
}

//#pragma mark - UISearchBar Delegate
//
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
//{
//    
//}
//
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    self.searchedText = searchText;
//}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self highlightOffCategoriesButtons];
    [self queryAXCGiphy:searchBar.text];
    
    [searchBar resignFirstResponder];
}

#pragma mark - UIResponder

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    /*----------------------------------------------------------------------------*
//     * Dismiss keyboard when tapping the other area outside.
//     *----------------------------------------------------------------------------*/
//    [self.searchBar resignFirstResponder];
//}

#pragma UIAlertView

- (void)didAlertStates:(NSUInteger)status
{
    switch (status) {
        case AlertStateNoSearchResults:
        {
            // show an alert message if no search results
//            [[[UIAlertView alloc] initWithTitle:@"No Search Results" message:@"Type again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
            break;
        case AlertStateNoNetwork:
        {
            // Show an alert message if a device is out of connection.
//            [[[UIAlertView alloc] initWithTitle:@"No Network" message:@"You appear to be offline. Please connect to view this page." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
            break;
            
    }
}

#pragma mark - Private Methods

- (void)createCategoriesButtons
{
    /*----------------------------------------------------------------------------*
     * Create GiphyCategories Scroll View.
     *----------------------------------------------------------------------------*/
    self.giphyCategoriesScrollView.delegateClass = self;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"GiphyServices" ofType:@"plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *plistArray = [NSArray arrayWithArray:[dic objectForKey:@"categories"]];
    NSLog(@"category list:%@", plistArray);
    self.categoriesButtons = [self.giphyCategoriesScrollView createScrollViewWithButtons:plistArray
                                                                                selector:@selector(buttonInChirpScrollViewPressed:)];
}

- (void)highlightOffCategoriesButtons
{
    // Highlight all buttons Off
    for (UIButton *thisButton in self.categoriesButtons)
        thisButton.backgroundColor = [UIColor whiteColor];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    
    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
//    [self.nextKeyboardButton setTitleColor:textColor forState:UIControlStateNormal];
}

@end
