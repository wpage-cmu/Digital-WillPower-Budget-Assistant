#FP Final Writeup - Digital WillPower
##Website Description
The point of this product is to help people improve their decision making on how to spend money. Too often do we react to our budget at the end of the month realizing we spent too much, just to assure ourselves we'll spend less over the course of the next month and inveitably not changing our behavior. 

WillPower aims to provide the right info at the right time for users to make decisions more in-line with their long term goals. A user enters their target budget for various categories (e.g. spend $200/wk eating out), and WillPower delivers that information when the user is in a place of interest for that category (e.g. a restaurant).

This is interesting because it is a real problem for people. Almost everyone I have shown the product to has immediately understood and resonated with the product, some even asking how to download it. The target audience is anyone trying to improve their spending habits and doesn't mind their location being tracked by an application.


##User Interaction
This is a mobile app, meant for use on an iPhone. This app is responsive to both standard and Pro Max sizes of iPhones and can be used in both landscape and portrait orientation. 

Upon launching the app for the first time, a user is met with their first target screen:
IMAGE OF ADD TARGET SCREEN

Once a user adds their first target, their location begins being tracked (locationManager). Once their location is established as stable (evaluateStability), WillPower scans 15m around them to search for PoIs for which the user has a target made (checkLocation). Then, once the PoIs are retrieved, WillPower uses the closest one as the user's location. Finally, the user receives a notification with their target budget for the category of the PoI they are in (sendNotification). 
IMAGE OF NOTIFICATION

The user can edit or add more targets in the main UI (targetDetails.swift).


##External Tool


##Design Iteration

##Implementation Challenge

##GenAI Use

##Demo Video
