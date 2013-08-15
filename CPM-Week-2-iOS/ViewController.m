//
//  ViewController.m
//  CPM-Week-2-iOS
//
//  Created by Jeremy Fox on 8/12/13.
//  Copyright (c) 2013 rentpath. All rights reserved.
//

#import "ViewController.h"
#import "TableCell.h"

#define SQLog(message) NSLog(@"Performing SQL Statement: %@", message);

typedef NS_ENUM(NSInteger, FilterOption) {
    FilterOptionALL,
    FilterOptionFREE,
    FilterOptionPAID
};

// Database Name
static NSString* const ITUNES_SEARCH_DB            = @"itunessearch";

// Searches Table
static NSString* const SEARCHES_TABLE              = @"searches";
static NSString* const SEARCHES_ID                 = @"id";
static NSString* const SEARCHES_SEARCH_ID          = @"searchId";

// Results Table
static NSString* const RESULTS_TABLE               = @"results";
static NSString* const RESULTS_ID                  = @"id";
static NSString* const RESULTS_ARTIST_ID           = @"artistId";
static NSString* const RESULTS_ARTIST_NAME         = @"artistName";
static NSString* const RESULTS_ARTIST_VIEW_URL     = @"artistViewUrl";
static NSString* const RESULTS_ARTWORK_URL_100     = @"artworkUrl100";
static NSString* const RESULTS_COLLECTION_ID       = @"collectionId";
static NSString* const RESULTS_COLLECTION_NAME     = @"collectionName";
static NSString* const RESULTS_COLLECTION_PRICE    = @"collectionPrice";
static NSString* const RESULTS_COLLECTION_VIEW_URL = @"collectionViewUrl";
static NSString* const RESULTS_COUNTRY             = @"country";
static NSString* const RESULTS_CURRENCY            = @"currency";
static NSString* const RESULTS_KIND                = @"kind";
static NSString* const RESULTS_PRIMARY_GENRE_NAME  = @"primaryGenreName";
static NSString* const RESULTS_RELEASE_DATE        = @"releaseDate";
static NSString* const RESULTS_TRACK_COUNT         = @"trackCount";
static NSString* const RESULTS_TRACK_ID            = @"trackId";
static NSString* const RESULTS_TRACK_NAME          = @"trackName";
static NSString* const RESULTS_TRACK_PRICE         = @"trackPrice";
static NSString* const RESULTS_TRACK_VIEW_URL      = @"trackViewUrl";
static NSString* const RESULTS_SEARCH_ID           = @"searchId";

// Genres Table
static NSString* const GENRES_TABLE                = @"genres";
static NSString* const GENRES_ID                   = @"id";
static NSString* const GENRES_RESULT_ID            = @"resultId";
static NSString* const GENRES_GENRE                = @"genre";

// Genre ID's Tbale
static NSString* const GENRE_IDS_TABLE             = @"genre_id_strings";
static NSString* const GENRE_IDS_ID                = @"id";
static NSString* const GENRE_IDS_RESULT_ID         = @"resultId";
static NSString* const GENRE_IDS_GENRE_ID          = @"genreId";

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) ZIMDbConnection* db;
@property (nonatomic, strong) NSArray* data;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self.tableView registerClass:[TableCell class] forCellReuseIdentifier:CELL_ID];
    
    self.db = [[ZIMDbConnection alloc] initWithDataSource:ITUNES_SEARCH_DB];
    if (self.db) {
        /**
         * @return First drop any pre-existing tables to ensure we start with a clean db every launch
         */
        [self dropAllTables];
        
        /**
         * @return Create Tables
         */
        [self createTables];
        
        /**
         * @return Insert all data
         */
        [self insertData];
        
        self.data = [self getRecords:FilterOptionALL];
        
        [self.tableView reloadData];
    }
}

#pragma mark - DROP TABLES

- (void)dropAllTables {
    [self dropSearchesTable];
    [self dropResultsTable];
    [self dropGenresTable];
    [self dropGenreIDsTable];
}

- (void)dropSearchesTable {
    ZIMSqlDropTableStatement *drop = [[ZIMSqlDropTableStatement alloc] init];
    [drop table:SEARCHES_TABLE exists:YES];
    NSString *statement = [drop statement];
    SQLog(statement)
    [self.db execute:statement];
}

- (void)dropResultsTable {
    ZIMSqlDropTableStatement *drop = [[ZIMSqlDropTableStatement alloc] init];
    [drop table:RESULTS_TABLE exists:YES];
    NSString *statement = [drop statement];
    SQLog(statement)
    [self.db execute:statement];
}

- (void)dropGenresTable {
    ZIMSqlDropTableStatement *drop = [[ZIMSqlDropTableStatement alloc] init];
    [drop table:GENRES_TABLE exists:YES];
    NSString *statement = [drop statement];
    SQLog(statement)
    [self.db execute:statement];
}

- (void)dropGenreIDsTable {
    ZIMSqlDropTableStatement *drop = [[ZIMSqlDropTableStatement alloc] init];
    [drop table:GENRE_IDS_TABLE exists:YES];
    NSString *statement = [drop statement];
    SQLog(statement)
    [self.db execute:statement];
}

#pragma mark - CREATE TABLES

- (void)createTables {
    [self createSearchesTable];
    [self createResultsTable];
    [self createGenresTable];
    [self createGenreIdsTable];
}

- (void)createSearchesTable {
    ZIMSqlCreateTableStatement *create = [[ZIMSqlCreateTableStatement alloc] init];
    [create table:SEARCHES_TABLE];
    [create column:SEARCHES_ID type:ZIMSqlDataTypeInteger defaultValue:ZIMSqlDefaultValueIsAutoIncremented];
    [create column:SEARCHES_SEARCH_ID type:ZIMSqlDataTypeInteger];
    NSString* statement = [create statement];
    SQLog(statement)
    NSNumber* result = [self.db execute:statement];
    NSLog(@"Searches Table %@ created!", ([result intValue] == 1) ? @"Was" : @"Was NOT");
}

- (void)createResultsTable {
    ZIMSqlCreateTableStatement *create = [[ZIMSqlCreateTableStatement alloc] init];
    [create table:RESULTS_TABLE];
    [create column:RESULTS_ID                   type:ZIMSqlDataTypeInteger defaultValue:ZIMSqlDefaultValueIsAutoIncremented];
    [create column:RESULTS_ARTIST_ID            type:ZIMSqlDataTypeInteger];
    [create column:RESULTS_ARTIST_NAME          type:ZIMSqlDataTypeVarChar(255)];
    [create column:RESULTS_ARTIST_VIEW_URL      type:ZIMSqlDataTypeVarChar(255)];
    [create column:RESULTS_ARTWORK_URL_100      type:ZIMSqlDataTypeVarChar(255)];
    [create column:RESULTS_COLLECTION_ID        type:ZIMSqlDataTypeInteger];
    [create column:RESULTS_COLLECTION_NAME      type:ZIMSqlDataTypeVarChar(255)];
    [create column:RESULTS_COLLECTION_PRICE     type:ZIMSqlDataTypeInteger];
    [create column:RESULTS_COLLECTION_VIEW_URL  type:ZIMSqlDataTypeVarChar(255)];
    [create column:RESULTS_COUNTRY              type:ZIMSqlDataTypeVarChar(255)];
    [create column:RESULTS_CURRENCY             type:ZIMSqlDataTypeVarChar(255)];
    [create column:RESULTS_KIND                 type:ZIMSqlDataTypeVarChar(255)];
    [create column:RESULTS_PRIMARY_GENRE_NAME   type:ZIMSqlDataTypeVarChar(255)];
    [create column:RESULTS_RELEASE_DATE         type:ZIMSqlDataTypeVarChar(255)];
    [create column:RESULTS_TRACK_COUNT          type:ZIMSqlDataTypeInteger];
    [create column:RESULTS_TRACK_ID             type:ZIMSqlDataTypeInteger];
    [create column:RESULTS_TRACK_NAME           type:ZIMSqlDataTypeVarChar(255)];
    [create column:RESULTS_TRACK_PRICE          type:ZIMSqlDataTypeVarChar(255)];
    [create column:RESULTS_TRACK_VIEW_URL       type:ZIMSqlDataTypeVarChar(255)];
    [create column:RESULTS_SEARCH_ID            type:ZIMSqlDataTypeInteger];
    NSString* statement = [create statement];
    SQLog(statement)
    NSNumber* result = [self.db execute:statement];
    NSLog(@"Results Table %@ created!", ([result intValue] == 1) ? @"Was" : @"Was NOT");
}

- (void)createGenresTable {
    ZIMSqlCreateTableStatement *create = [[ZIMSqlCreateTableStatement alloc] init];
    [create table:GENRES_TABLE];
    [create column:GENRES_ID type:ZIMSqlDataTypeInteger defaultValue:ZIMSqlDefaultValueIsAutoIncremented];
    [create column:GENRES_GENRE type:ZIMSqlDataTypeVarChar(255)];
    [create column:GENRES_RESULT_ID type:ZIMSqlDataTypeInteger];
    NSString* statement = [create statement];
    SQLog(statement)
    NSNumber* result = [self.db execute:statement];
    NSLog(@"Genres Table %@ created!", ([result intValue] == 1) ? @"Was" : @"Was NOT");
}

- (void)createGenreIdsTable {
    ZIMSqlCreateTableStatement *create = [[ZIMSqlCreateTableStatement alloc] init];
    [create table:GENRE_IDS_TABLE];
    [create column:GENRE_IDS_ID type:ZIMSqlDataTypeInteger defaultValue:ZIMSqlDefaultValueIsAutoIncremented];
    [create column:GENRE_IDS_GENRE_ID type:ZIMSqlDataTypeVarChar(255)];
    [create column:GENRE_IDS_RESULT_ID type:ZIMSqlDataTypeInteger];
    NSString* statement = [create statement];
    SQLog(statement)
    NSNumber* result = [self.db execute:statement];
    NSLog(@"Genre IDs Table %@ created!", ([result intValue] == 1) ? @"Was" : @"Was NOT");
}

#pragma mark - INSERT DATA

- (void)insertData {
    [self insertSearch];
    [self insertResults];
    [self insertGenres];
    [self insertGenreIDs];
}

- (void)insertSearch {
    ZIMSqlInsertStatement* insert = [[ZIMSqlInsertStatement alloc] init];
    [insert into:SEARCHES_TABLE];
    [insert column:SEARCHES_SEARCH_ID value:@111];
    NSString* statement = [insert statement];
    SQLog(statement)
    [self.db execute:statement];
}

- (void)insertResults {
    ZIMSqlInsertStatement* insert = [[ZIMSqlInsertStatement alloc] init];
    [insert into:RESULTS_TABLE];
    [insert column:RESULTS_ARTIST_ID value:@155862268];
    [insert column:RESULTS_ARTIST_NAME value:@"Abigail Hilton"];
    [insert column:RESULTS_ARTIST_VIEW_URL value:@"https://itunes.apple.com/us/artist/podiobooks.com/id155862268?mt=2&uo=4"];
    [insert column:RESULTS_ARTWORK_URL_100 value:@"http://a5.mzstatic.com/us/r30/Podcasts/v4/40/83/b0/4083b046-0b6a-d938-d12e-88ef5c0893fa/mza_6274906439174656865.100x100-75.jpg"];
    [insert column:RESULTS_COLLECTION_ID value:@427113696];
    [insert column:RESULTS_COLLECTION_NAME value:@"The Guild of the Cowry Catchers, Book 2 Flames"];
    [insert column:RESULTS_COLLECTION_PRICE value:@0];
    [insert column:RESULTS_COLLECTION_VIEW_URL value:@"https://itunes.apple.com/us/podcast/guild-cowry-catchers-book/id427113696?mt=2&uo=4"];
    [insert column:RESULTS_COUNTRY value:@"USA"];
    [insert column:RESULTS_CURRENCY value:@"USD"];
    [insert column:RESULTS_KIND value:@"podcast"];
    [insert column:RESULTS_PRIMARY_GENRE_NAME value:@"Literature"];
    [insert column:RESULTS_RELEASE_DATE value:@"2011-03-18T05:50:00Z"];
    [insert column:RESULTS_TRACK_COUNT value:@16];
    [insert column:RESULTS_TRACK_ID value:@427113696];
    [insert column:RESULTS_TRACK_NAME value:@"The Guild of the Cowry Catchers, Book 2 Flames"];
    [insert column:RESULTS_TRACK_PRICE value:@"Abigail"];
    [insert column:RESULTS_TRACK_VIEW_URL value:@"https://itunes.apple.com/us/podcast/guild-cowry-catchers-book/id427113696?mt=2&uo=4"];
    [insert column:RESULTS_SEARCH_ID value:@1];
    NSString* statement = [insert statement];
    SQLog(statement)
    [self.db execute:statement];
    
    [insert into:RESULTS_TABLE];
    [insert column:RESULTS_ARTIST_ID value:@325211830];
    [insert column:RESULTS_ARTIST_NAME value:@"Spinner.com"];
    [insert column:RESULTS_ARTIST_VIEW_URL value:@"https://itunes.apple.com/us/artist/aol-media/id325211830?mt=2&uo=4"];
    [insert column:RESULTS_ARTWORK_URL_100 value:@"http://a1.mzstatic.com/us/r30/Podcasts/v4/66/44/17/664417b4-532b-4f6a-7a0e-147f6414d523/mza_4525175260731493267.100x100-75.jpg"];
    [insert column:RESULTS_COLLECTION_ID value:@309328973];
    [insert column:RESULTS_COLLECTION_NAME value:@"MP3 of the Day: A free Spinner-approved MP3 download of artists you need to know."];
    [insert column:RESULTS_COLLECTION_PRICE value:@0];
    [insert column:RESULTS_COLLECTION_VIEW_URL value:@"https://itunes.apple.com/us/podcast/mp3-day-free-spinner-approved/id309328973?mt=2&uo=4"];
    [insert column:RESULTS_COUNTRY value:@"USA"];
    [insert column:RESULTS_CURRENCY value:@"USD"];
    [insert column:RESULTS_KIND value:@"podcast"];
    [insert column:RESULTS_PRIMARY_GENRE_NAME value:@"Music"];
    [insert column:RESULTS_RELEASE_DATE value:@"2013-04-26T03:50:00Z"];
    [insert column:RESULTS_TRACK_COUNT value:@20];
    [insert column:RESULTS_TRACK_ID value:@309328973];
    [insert column:RESULTS_TRACK_NAME value:@"MP3 of the Day: A free Spinner-approved MP3 download of artists you need to know."];
    [insert column:RESULTS_TRACK_PRICE value:@5];
    [insert column:RESULTS_TRACK_VIEW_URL value:@"https://itunes.apple.com/us/podcast/mp3-day-free-spinner-approved/id309328973?mt=2&uo=4"];
    [insert column:RESULTS_SEARCH_ID value:@1];
    statement = [insert statement];
    SQLog(statement)
    [self.db execute:statement];
    
    [insert into:RESULTS_TABLE];
    [insert column:RESULTS_ARTIST_ID value:@256201037];
    [insert column:RESULTS_ARTIST_NAME value:@"Fraser Cain & Dr. Pamela Gay"];
    [insert column:RESULTS_ARTIST_VIEW_URL value:@"https://itunes.apple.com/us/artist/wizzard-media/id256201037?mt=2&uo=4"];
    [insert column:RESULTS_ARTWORK_URL_100 value:@"http://a5.mzstatic.com/us/r30/Features/v4/dd/dd/ad/ddddad15-13df-6813-7d05-d81e45d88d9e/mza_5442136597615139731.100x100-75.jpg"];
    [insert column:RESULTS_COLLECTION_ID value:@191636169];
    [insert column:RESULTS_COLLECTION_NAME value:@"Astronomy Cast"];
    [insert column:RESULTS_COLLECTION_PRICE value:@99];
    [insert column:RESULTS_COLLECTION_VIEW_URL value:@"https://itunes.apple.com/us/podcast/astronomy-cast/id191636169?mt=2&uo=4"];
    [insert column:RESULTS_COUNTRY value:@"USA"];
    [insert column:RESULTS_CURRENCY value:@"USD"];
    [insert column:RESULTS_KIND value:@"podcast"];
    [insert column:RESULTS_PRIMARY_GENRE_NAME value:@"Natural Sciences"];
    [insert column:RESULTS_RELEASE_DATE value:@"2013-06-24T12:00:00Z"];
    [insert column:RESULTS_TRACK_COUNT value:@300];
    [insert column:RESULTS_TRACK_ID value:@191636169];
    [insert column:RESULTS_TRACK_NAME value:@"Astronomy Cast"];
    [insert column:RESULTS_TRACK_PRICE value:@0];
    [insert column:RESULTS_TRACK_VIEW_URL value:@"https://itunes.apple.com/us/podcast/astronomy-cast/id191636169?mt=2&uo=4"];
    [insert column:RESULTS_SEARCH_ID value:@1];
    statement = [insert statement];
    SQLog(statement)
    [self.db execute:statement];
}

- (void)insertGenres {
    
}

- (void)insertGenreIDs {
    
}

#pragma mark - SELECT DATA

- (NSArray*)getRecords:(FilterOption)filterOption {
    ZIMSqlSelectStatement* select = [[ZIMSqlSelectStatement alloc] init];
    NSArray* columns = @[
        RESULTS_ID,
        RESULTS_ARTIST_ID,
        RESULTS_ARTIST_NAME,
        RESULTS_ARTIST_VIEW_URL,
        RESULTS_ARTWORK_URL_100,
        RESULTS_COLLECTION_ID,
        RESULTS_COLLECTION_NAME,
        RESULTS_COLLECTION_PRICE,
        RESULTS_COLLECTION_VIEW_URL,
        RESULTS_COUNTRY,
        RESULTS_CURRENCY,
        RESULTS_KIND,
        RESULTS_PRIMARY_GENRE_NAME,
        RESULTS_RELEASE_DATE,
        RESULTS_TRACK_COUNT,
        RESULTS_TRACK_ID,
        RESULTS_TRACK_NAME,
        RESULTS_TRACK_PRICE,
        RESULTS_TRACK_VIEW_URL,
        RESULTS_SEARCH_ID
    ];
    [select columns:columns];
    [select from:RESULTS_TABLE];
    
    switch (filterOption) {
        case FilterOptionALL:
            [select where:RESULTS_SEARCH_ID operator:ZIMSqlOperatorEqualTo value:@1];
            break;
            
        case FilterOptionFREE:
            [select where:RESULTS_SEARCH_ID operator:ZIMSqlOperatorEqualTo value:@1 connector:ZIMSqlConnectorAnd];
            [select where:RESULTS_COLLECTION_PRICE operator:ZIMSqlOperatorEqualTo value:@0];
            break;
            
        case FilterOptionPAID:
            [select where:RESULTS_SEARCH_ID operator:ZIMSqlOperatorEqualTo value:@1 connector:ZIMSqlConnectorAnd];
            [select where:RESULTS_COLLECTION_PRICE operator:ZIMSqlOperatorGreaterThan value:@0];
            break;
            
        default:
            break;
    }
    
    NSString* statement = [select statement];
    SQLog(statement)
    return [self.db query:statement];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* const CELL_ID = @"data_cell_identifier";
    TableCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    NSDictionary* result = [self.data objectAtIndex:indexPath.row];
    cell.title.text = [result objectForKey:RESULTS_ARTIST_NAME];
    cell.subTitle.text = [result objectForKey:RESULTS_COLLECTION_NAME];
    NSString* price = [NSString stringWithFormat:@"$%@", [result objectForKey:RESULTS_COLLECTION_PRICE]];
    cell.price.text = [NSString stringWithFormat:@"%@", [price isEqualToString:@"$0"] ? @"FREE" : price];
    return cell;
}

#pragma mark - Segmented Control

- (IBAction)valueChanged:(UISegmentedControl *)sender {
    switch (self.filterControl.selectedSegmentIndex) {
        case 0:
            self.data = [self getRecords:FilterOptionALL];
            break;
            
        case 1:
            self.data = [self getRecords:FilterOptionFREE];
            break;
            
        case 2:
            self.data = [self getRecords:FilterOptionPAID];
            break;
    }
    [self.tableView reloadData];
}

@end
