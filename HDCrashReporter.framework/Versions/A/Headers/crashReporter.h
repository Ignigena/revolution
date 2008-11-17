//
//  HDCrashReporter.h
//
//  HDCrashReporter is a framework to send back to the developer the crash reports 
//  and the console log after a crash.
//  Copyright (C) 2006 Humble Daisy
//
//  This library is free software; you can redistribute it and/or
//  modify it under the terms of the GNU Lesser General Public
//  License as published by the Free Software Foundation; either
//  version 2.1 of the License, or (at your option) any later version.
//
//  This library is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//  Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public
//  License along with this library; if not, write to the Free Software
//  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
//
//  For more information contact: developers@profcast.com
//

#import <Cocoa/Cocoa.h>


@interface HDCrashReporter : NSWindowController 
{
  BOOL sendCrashReport;
  BOOL sendConsoleLog;
  BOOL showDetails;
  BOOL isSending;
  NSAttributedString *crashReportData;
  NSAttributedString *consoleLogReport;
  NSAttributedString *comments;
  IBOutlet NSPanel *sendingPanel;
}

+ (BOOL) newCrashLogExists;
+ (void) doCrashSubmitting;

- (IBAction) sendReport: (id) sender;
- (IBAction) showDetails: (id) sender;

- (BOOL)sendCrashReport;
- (void)setSendCrashReport:(BOOL)flag;
- (BOOL)sendConsoleLog;
- (void)setSendConsoleLog:(BOOL)flag;
- (BOOL)showDetails;
- (void)setShowDetails:(BOOL)flag;
- (NSAttributedString *)crashReportData;
- (void)setCrashReportData:(NSAttributedString *)aCrashReportData;
- (NSAttributedString *)consoleLogReport;
- (void)setConsoleLogReport:(NSAttributedString *)aConsoleLogReport;
- (NSAttributedString *)comments;
- (void)setComments:(NSAttributedString *)aComments;
- (BOOL)isSending;
- (void)setIsSending:(BOOL)flag;

- (NSString*) companyName;
- (NSString*) applicationName;
+ (NSString*) applicationName;
+ (NSString*) lastCrashReport;
+ (NSString*) consoleLog;
@end
