# FP Final Writeup - Digital WillPower
## Website Description
The point of this product is to help people improve their decision making on how to spend money. Too often do we react to our budget at the end of the month realizing we spent too much, just to assure ourselves we'll spend less over the course of the next month and inveitably not changing our behavior. 

WillPower aims to provide the right info at the right time for users to make decisions more in-line with their long term goals. A user enters their target budget for various categories (e.g. spend $200/wk eating out), and WillPower delivers that information when the user is in a place of interest for that category (e.g. a restaurant).

This is interesting because it is a real problem for people. Almost everyone I have shown the product to has immediately understood and resonated with the product, some even asking how to download it. The target audience is anyone trying to improve their spending habits and doesn't mind their location being tracked by an application.


## User Interaction
This is a mobile app, meant for use on an iPhone. This app is responsive to both standard and Pro Max sizes of iPhones and can be used in both landscape and portrait orientation. 

Upon launching the app for the first time, a user is met with their first target screen:
IMAGE OF ADD TARGET SCREEN

Once a user adds their first target, their location begins being tracked (locationManager). Once their location is established as stable (evaluateStability), WillPower scans 15m around them to search for PoIs for which the user has a target made (checkLocation). Then, once the PoIs are retrieved, WillPower uses the closest one as the user's location. Finally, the user receives a notification with their target budget for the category of the PoI they are in (sendNotification). 
IMAGE OF NOTIFICATION

The user can edit or add more targets in the main UI (targetDetails.swift).


## External Tool
I used MapKit. MapKit is an API developed by Apple that enables you to use place data (category, name, etc.) that you can see in Apple Maps. At first I was going to use Google Places API, as that is what I had heard of before, but it became immediately clear that using MapKit would be cleaner since I developed the app in Swift.

This sits behind the above notification logic, enabling WillPower to use both the category (to send the relevant target) and discern that a user in even in a PoI to begin with.

## Design Iteration
I iterated my design in several key chunks. 

First was color pallette. I made a color pallette of mainly creme, forest green, red and dark navy blue to use, but i changed that to be system black/white. The reason for this is twofold. First off, I suck at color selection and my pallette just didn't look that great (as per 3 users I tested the first iteration with). Second, Swift has means to handle dark mode and light mode automatically, and I find that to be a delightful feature in other apps that I use.

The second iteration was in onboarding. After FP3, I got feedback from my TA and classmates to make it clearer what a target is and how to set it up. Now, if a user has 0 targets, they are met with the target creation form (addTarget.swift). I kept this interface very simple: pick your category, your budget, and the timeframe you want to spend that over. This will ensure that a user has done the 'Aha' action that is key to a successful usage of the product.


## Implementation Challenge
The largest implementation challenge was making a robust notification algorithm. Location can be pretty sensitive, so I accounted for 'snaps' in location data by controlling 'horizontal accuracy' (disincluded location samples from the device where the confidence was low). Secondly, how long 


## GenAI Use

## Demo Video
