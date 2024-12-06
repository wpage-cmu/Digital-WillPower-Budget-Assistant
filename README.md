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
The largest implementation challenge was making a robust notification algorithm. Location can be pretty sensitive, so I accounted for 'snaps' in location data by controlling 'horizontal accuracy' (disincluded location samples from the device where the confidence was low). Secondly, the search algorithm was tough to make robust. I continuously got a logic error where the search would bring back the locations nearest the coordinate for the city I was in (so when I was testing as if I was at campus Chipotle, it would yield Downtown results). This was resolved by expanding the search radius! Very counterintuitive! The problem was MapKit doesn't love it when you search with too precise accuracy, and would fall back to a region/city search rather than the radius you set up.

## GenAI Use
I used ChatGPT and Claude in this project, and think Claude ended up being way better. I wanted to try out different techniques of using GenAI while programming, so I tried 3 main types of interaction:
- complete unreliance on GenAI (doing the full programming myself and using typical google/reddit/stack overflow searching to figure it out. This is how I built most of the targetReminder, addTarget, and the targetDetails screen)
- semi-reliance, where I would use GenAI as first pass, interpret the code to ensure its quality and did what I wanted to do. Then, continued to prompt to refine any parts that were not right, then used that code. I used this method for debugging mainly, and it was very helpful. This also helped me figure out the search radius problem above.
- complete reliance, where I would blindly trust, paste in, and troubleshoot from there. This method was not good, and I found myself wasting a lot of time with it. Almost none of my project ended up getting built with this except for the basic UI components as I got more familiar with Swift.

To reflect on this, GenAI is incredible in that it lowers the barrier to entry into new technogologies. I had barely worked with Swift and never worked with MapKit, but I was able to build this project successfully. That said, I can definitely see how easy it is to rely too much on the technology. It was an act of discipline to not overrely on GenAI in order to preserve my learning from the class.

## Demo Video
