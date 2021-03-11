# WatchListStockApp by Preetham Kesineni
Challenge Program to create a watchlist Stock app for TastyTrade

## Instructions to download and run:
1. Download and unzip the file
2. Open terminal and navigate to directory with project
3. Run ```pod init``` in terminal
4. Open pod file in any text editor
5. Add the following lines below the line ```#pods for watchlist stock app``` (case sensitive)

```
pod 'RealmSwift'
pod 'SwiftyJSON'
pod 'Alamofire'
pod 'Charts'
pod 'ChartsRealm'
```
6. return to terminal and run ```pod install```
7. Now open the project (**NOTE**: be sure to open the file WatchListStockApp.xcworkspace **NOT** WatchListStockApp.xcodeproj) This is to ensure the libraries from the pod file are availible. 
8. On First run there will be a delay as xcode indexes and processes the files. 
9. Once Complete Select the new Scheme option next to the play and stop buttons and select the Watchlist Stock app
10. Now change the Simulator to simulate iPhone 12 Pro (preferably ios 14.3) as this is the optimal simulator to ensure proper view element organization
11. Run and app and Continue

## Developers Notes:
  - The project was fun and exciting for me. I enjoyed the challenge offering me a refresher on some older swift skills as well as an opportunity to try new things and styles.
  - I found a lot of good practice in using new and old open source libraries.
  - Most of the requirements should be easy to view and observe with one exception 
    -   (Deletion is done by swiping left on a table cell in the main view and the watchlist management view. This is an oversight I am aware of with more time I would offer a tutorial to indicate this. )
  ### Things I would like to fix if I had more time
        - Adding new watchlists you can add a watch list with the same name and it will not add a new one
        - Adding new watchlists can leave the name blank and can potentially crash the app
        - Overall improvements on the graph such as adding red and green color variation based on price diffences
        - Adding alternative graphs such as candle stick graph
        - Make a tutorial to help illustrate the functions of the app
        - Make the refresh much cleaner and less clunky
        - fix internet connection disruption issues
        - My Search uses the sandbox iexCloud link rather than the normal which offers similar functionality just doesn't use credits and is slower on uptake  unresolved JSON bug but doesn't affect MVP
       
