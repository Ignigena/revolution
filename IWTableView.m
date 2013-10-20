#import "IWTableView.h"
#import "IWTableCellText.h"
#import "MyDocument.h"

@implementation IWTableView

- (void) awakeFromNib
{
	[self setRowHeight: 18];
	
	IWTableCellText *tableCellText = [[IWTableCellText alloc] init];
	[[self tableColumns][0] setDataCell: tableCellText];
}

- (id)_highlightColorForCell:(NSCell *)cell
{
	// Highlight selected row colour
	return [NSColor colorWithDeviceRed:51/255.0 green:104/255.0 blue:192/255.0 alpha:1.0];
}

- (void)keyDown:(NSEvent *)theEvent
{
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    
    if(key == NSDeleteCharacter) {
        if([self selectedRow] == -1) {
            NSBeep();
        }
        
        if (![[self.window firstResponder] isKindOfClass:[NSText class]]) {
            [arrayController remove:nil];
            return;
        }
    }

    [super keyDown:theEvent];
}

@end
