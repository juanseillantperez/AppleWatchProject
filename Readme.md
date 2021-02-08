#  AppleWatch + HealthKit Example Project

This document contains a brief explanation of the Apple Watch integration with HealthKit.

## 1. Apple Watch and IPhone app Comminication

This example contains a basic communication between the AppleWatch App and the iPhone app to. 

You select a Workout type in the phone app and that will start a workout on your Apple Watch trought HealthKit. 

When the workout starts, the watch app will send the calories and the HeartRate info to the iPhone App, also the IPhone app will send messages to pause, resume, discard or end the workout.

When the workout ends the watch will show you a summary screen with the calories burned and the AVG Heart rate.

In the IPhone App you also can navigate to a Workout History screen, that contains all the workouts that the user has saved in HealthKit. You have an example to get the AVG HeartRate when you select a workout in the list.

## 2. RxSwift and RxCocoa

I'm using RxSwift and RxCocoa to simplify the connection between tableViews and the data to display, instead of implement all the delegates methods and call `tableView.reladData()` each time the data changes.

Also the way I connected the UIButton with the interaction is more clear and legible using this SDK.

## 3. HealthKit

In this example I am only requesting and checking permission for read and write Workouts, calories burned and heartRate.

 I can also request permission for user age, bodyMass or height and, in the future, use that info to calculate the caloriesBurned based on that info and the type of the workout if the user denied permission to read the caloriesBurned from Healthkit

I'm requesting a limit of 100 Healtkit workouts with today as the end date, you can remove that limit and Healthkit will try to load all the workouts from Healthkit but that query could fail since the user maybe has thousands of workouts, so maybe you need to implement a pagination usign that limit and the stopInt value from the last workout, or only request the workouts from the user since a startDate less that a year. If you think in a healthy person that perform 3-4 workouts per week, you have 12-16 workouts per month and 144-196 per year.

## 4.Futures steps

-Better communication between the AppleWatch and the Iphone App to handle errors in the communication.

-Handle a timer in the AppleWatch to show the elapsed time of the workout 

-Manual log of Workouts in HealthKit. I already coded the logic to saved it but nothing in the UI.

-Filter the workout history based on the `sourceApp`. I already has the logic to detect if the workouts was logged for my app or for other (see `isOtherAppWorkout`field in `HealthkitWorkout` ) 

-Start using all this information maybe with MachineLearning or maybe with a backend to track the user info and perform a fitness app.