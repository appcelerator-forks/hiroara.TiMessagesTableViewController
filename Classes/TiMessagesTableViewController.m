//
//  TiMessagesTableViewController.m
//  TiMessagesTableViewController
//
//  Created by Arai Hiroki on 2014/04/13.
//
//

#import "TiMessagesTableViewController.h"
#import "JSMessage.h"
#import "TiBubbleImagesViewFactory.h"
#import "ComArihiroMessagestableModule.h"

ComArihiroMessagestableModule *proxy;

@implementation TiMessagesTableViewController

@synthesize incomingBubbleColor;
@synthesize outgoingBubbleColor;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (void)viewDidLoad
{
    self.delegate = self;
    self.dataSource = self;
    
    self.messages = [[NSMutableArray alloc] init];

    [super viewDidLoad];
    
//    [[JSBubbleView appearance] setFont:[UIFont fontWithName:@"AppleGothic" size:12]];
    
    self.messageInputView.image = [[[ComArihiroMessagestableModule getShared] getAssetImage:@"input-bar-flat.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f)
        resizingMode:UIImageResizingModeStretch];

    [self setBackgroundColor:[UIColor whiteColor]];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
                                                                                           target:self
                                                                                           action:@selector(buttonPressed:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self scrollToBottomAnimated:NO];
}


#pragma mark - JSMessagesViewDelegate protocol
#pragma mark required


/**
 *  Tells the delegate that the user has sent a message with the specified text, sender, and date.
 *
 *  @param text   The text that was present in the textView of the messageInputView when the send button was pressed.
 *  @param sender The user who sent the message.
 *  @param date   The date and time at which the message was sent.
 */
- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    JSMessage* message = [[JSMessage alloc] initWithText:text sender:sender date:date];
    [self.messages addObject:message];
    [self finishSend];
    [self scrollToBottomAnimated:YES];
}

/**
 *  Asks the delegate for the message type for the row at the specified index path.
 *
 *  @param indexPath The index path of the row to be displayed.
 *
 *  @return A constant describing the message type.
 *  @see JSBubbleMessageType.
 */
- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath {
    JSMessage *message = [self.messages objectAtIndex:indexPath.row];
    return message.sender == self.sender ? JSBubbleMessageTypeOutgoing : JSBubbleMessageTypeIncoming;
}

/**
 *  Asks the delegate for the bubble image view for the row at the specified index path with the specified type.
 *
 *  @param type      The type of message for the row located at indexPath.
 *  @param indexPath The index path of the row to be displayed.
 *
 *  @return A `UIImageView` with both `image` and `highlightedImage` properties set.
 *  @see JSBubbleImageViewFactory.
 */
- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIColor *color;
    if (type == JSBubbleMessageTypeOutgoing) {
        color = incomingBubbleColor != nil ? incomingBubbleColor : [UIColor js_bubbleBlueColor];
    } else {
        color = outgoingBubbleColor != nil ? outgoingBubbleColor : [UIColor js_bubbleLightGrayColor];
    }
    return [TiBubbleImagesViewFactory bubbleImageViewForType:type color:color];
}

/**
 *  Asks the delegate for the input view style.
 *
 *  @return A constant describing the input view style.
 *  @see JSMessageInputViewStyle.
 */
- (JSMessageInputViewStyle)inputViewStyle {
    return JSMessageInputViewStyleFlat;
}

#pragma mark optional

/**
 *  Asks the delegate if a timestamp should be displayed *above* the row at the specified index path.
 *
 *  @param indexPath The index path of the row to be displayed.
 *
 *  @return A boolean value specifying whether or not a timestamp should be displayed for the row at indexPath. The default value is `YES`.
 */
// - (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath {}

/**
 *  Asks the delegate to configure or further customize the given cell at the specified index path.
 *
 *  @param cell      The message cell to configure.
 *  @param indexPath The index path for cell.
 */
- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell messageType] == JSBubbleMessageTypeOutgoing) {
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
        
        if ([cell.bubbleView.textView respondsToSelector:@selector(linkTextAttributes)]) {
            NSMutableDictionary *attrs = [cell.bubbleView.textView.linkTextAttributes mutableCopy];
            [attrs setValue:[UIColor blueColor] forKey:UITextAttributeTextColor];
            
            cell.bubbleView.textView.linkTextAttributes = attrs;
        }
    }
    
    if (cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor lightGrayColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
    }
    
    if (cell.subtitleLabel) {
        cell.subtitleLabel.textColor = [UIColor lightGrayColor];
    }
    
#if TARGET_IPHONE_SIMULATOR
    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeNone;
#else
    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeAll;
#endif
}


/**
 *  Asks the delegate if should always scroll to bottom automatically when new messages are sent or received.
 *
 *  @return `YES` if you would like to prevent the table view from being scrolled to the bottom while the user is scrolling the table view manually, `NO` otherwise.
 */
- (BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}

/**
 *  Ask the delegate if the keyboard should be dismissed by panning/swiping downward. The default value is `YES`. Return `NO` to dismiss the keyboard by tapping.
 *
 *  @return A boolean value specifying whether the keyboard should be dismissed by panning/swiping.
 */
- (BOOL)allowsPanToDismissKeyboard
{
    return NO;
}

/**
 *  Asks the delegate for the send button to be used in messageInputView. Implement this method if you wish to use a custom send button. The button must be a `UIButton` or a subclass of `UIButton`. The button's frame is set for you.
 *
 *  @return A custom `UIButton` to use in messageInputView.
 */
// - (UIButton *)sendButtonForInputView {}

/**
 *  Asks the delegate for a custom cell reuse identifier for the row to be displayed at the specified index path.
 *
 *  @param indexPath The index path of the row to be displayed.
 *
 *  @return A string specifying the cell reuse identifier for the row at indexPath.
 */
// - (NSString *)customCellIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath {}


#pragma mark - JSMessagesViewDataSource
#pragma mark required
/**
 *  Asks the data source for the message object to display for the row at the specified index path. The message text is displayed in the bubble at index path. The message date is displayed *above* the row at the specified index path. The message sender is displayed *below* the row at the specified index path.
 *
 *  @param indexPath An index path locating a row in the table view.
 *
 *  @return An object that conforms to the `JSMessageData` protocol containing the message data. This value must not be `nil`.
 */
- (id<JSMessageData>)messageForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.messages objectAtIndex:indexPath.row];
}

/**
 *  Asks the data source for the imageView to display for the row at the specified index path with the given sender. The imageView must have its `image` property set.
 *
 *  @param indexPath An index path locating a row in the table view.
 *  @param sender    The name of the user who sent the message at indexPath.
 *
 *  @return An image view specifying the avatar for the message at indexPath. This value may be `nil`.
 */
- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender {
    return nil;
}


@end
