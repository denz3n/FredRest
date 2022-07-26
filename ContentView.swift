//
//  ContentView.swift
//  Shared
//
//  Created by Nathan Luksik on 5/26/21.
//

//current notes:
//dynamic type stuff should be fixed for iphone...
//need to edit default transition time to 10
//need to do the keypad thing: auto-open to start time hr, have a "done" button with it?, auto move to next field (start time min, then end time hr, then end time min)

import SwiftUI

//custom text field
struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool)->() = { _ in }
    var commit: ()->() = { }

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { placeholder }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
        }
    }
}

//get rid of keypad by tapping away
extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        tapGesture.name = "MyTapGesture"
        window.addGestureRecognizer(tapGesture)
    }
}
//"tap away from keypad" functionality does not override other gestures that have different meanings, such as double tapping to select text in TextView
//not sure if needed
extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false // set to `false` if you don't want to detect tap during other gestures
    }
}


//custom answer struct to be displayed on sheet (needed so that variables displayed on the sheet are bound correctly)
struct AnswerView: View {
    @Binding var schedLine1: String
    @Binding var schedLine2: String
    @Binding var schedLine3: String
    @Binding var schedLine4: String
    @Binding var schedLine5: String
    @Binding var schedLine6: String
    @Binding var schedLine7: String
    
    
    var body: some View {
        //for iphone users
        if UIDevice.current.localizedModel == "iPhone" {
            VStack {
                Text(schedLine1).font(Font.custom("Nunito-Light", size: 29.0)).multilineTextAlignment(.center).foregroundColor(Color("OffWhiteColor"))
                Text(" ")
                Text(schedLine2).font(Font.custom("Nunito-Light", size: 29.0)).multilineTextAlignment(.center).foregroundColor(Color("OffWhiteColor"))
                Text(" ")
                Text(schedLine3).font(Font.custom("Nunito-Light", size: 29.0)).multilineTextAlignment(.center).foregroundColor(Color("OffWhiteColor"))
                Text(" ")
                Text(schedLine4).font(Font.custom("Nunito-Light", size: 29.0)).multilineTextAlignment(.center).foregroundColor(Color("OffWhiteColor"))
                Text(schedLine5).font(Font.custom("Nunito-Light", size: 29.0)).multilineTextAlignment(.center).foregroundColor(Color("OffWhiteColor"))
                Text(schedLine6).font(Font.custom("Nunito-Light", size: 29.0)).multilineTextAlignment(.center).foregroundColor(Color("OffWhiteColor"))
                Text(schedLine7).font(Font.custom("Nunito-Light", size: 29.0)).multilineTextAlignment(.center).foregroundColor(Color("OffWhiteColor"))
            }
            
        }
        //for ipad users
        else {
            VStack {
                Text(schedLine1).font(.system(size: 50)).multilineTextAlignment(.center).foregroundColor(Color("OffWhiteColor"))
                Text(" ")
                Text(schedLine2).font(.system(size: 50)).multilineTextAlignment(.center).foregroundColor(Color("OffWhiteColor"))
                Text(" ")
                Text(schedLine3).font(.system(size: 50)).multilineTextAlignment(.center).foregroundColor(Color("OffWhiteColor"))
                Text(" ")
                Text(schedLine4).font(.system(size: 50)).multilineTextAlignment(.center).foregroundColor(Color("OffWhiteColor"))
                Text(schedLine5).font(.system(size: 50)).multilineTextAlignment(.center).foregroundColor(Color("OffWhiteColor"))
                Text(schedLine6).font(.system(size: 50)).multilineTextAlignment(.center).foregroundColor(Color("OffWhiteColor"))
                Text(schedLine7).font(.system(size: 50)).multilineTextAlignment(.center).foregroundColor(Color("OffWhiteColor"))
            }
            
        }
        
    }//end of body
}//end of struct


struct ContentView: View {
    
    /*
     -------------------------
     -------------------------
     -------------------------
     -------------------------
     -----STATE VARIABLES-----
     -------------------------
     -------------------------
     -------------------------
     -------------------------
     */
    
    //input for start time
    //@State var startHr = ""
    //@State var startHrInt:Int = 0
    //@State var startMin = ""
    //@State var startMinInt:Int = 0
    
    @State var startTime = ""
    @State var startTimeInt:Int = 0
    @State var endTime = ""
    @State var endTimeInt:Int = 0
    
    //input for end time
    //@State var endHr = ""
    //@State var endHrInt:Int = 0
    //@State var endMin = ""
    //@State var endMinInt:Int = 0
    
    
    
    //input for transition period length
    @State var tLen = ""
    @State var tLenInt:Int = 0
    //selection for 3 or 4 blocks
    @State var numBlocks = 3
    //(numBlock == 4)selection for what info is given (short, long, or ratio)
    @State var given = 0
    //(numBlock == 4) input for if given long
    @State var longHr = ""
    @State var longHrInt:Int = 0
    @State var longMin = ""
    @State var longMinInt:Int = 0
    //(numBlock == 4) input for if given short
    @State var shortHr = ""
    @State var shortHrInt:Int = 0
    @State var shortMin = ""
    @State var shortMinInt:Int = 0
    //(numBlock == 4) input for if given ratio
    @State var x = ""
    @State var xDouble:Double = 0.00
    //(numBlock == 4) sequence selected
    @State var sequence = "SSLL"
    //has Calculate button been pressed yet
    @State var showingPreview = false
    //are inputs all valid
    @State var allValid = true
    //error message
    @State var errorMessage = ""
    
    //answer array to be changed during calculations
    @State var schedule = [String](repeating: "", count: 7)
    
    //answer vars to be printed
    @State var schedLine1 = ""
    @State var schedLine2 = ""
    @State var schedLine3 = ""
    @State var schedLine4 = ""
    @State var schedLine5 = ""
    @State var schedLine6 = ""
    @State var schedLine7 = ""
    
    //initialize custom picker appearance
    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color("OffWhiteColor"))
        //let font = UIFont.systemFont(ofSize: 30)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30), .foregroundColor: UIColor(Color("OffWhiteColor"))], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color("DarkGrayBackColor"))], for: .selected)
        UISegmentedControl.appearance().backgroundColor = UIColor(Color("GrayBackColor"))

    }
        
    /*
     --------------------------
     --------------------------
     --------------------------
     --------------------------
     -------BODY CONTENT-------
     --------------------------
     --------------------------
     --------------------------
     --------------------------
     */
    
    var body: some View {
        
        //view for iphone
        /*
         ---------------------------
         ---------------------------
         ---------------------------
         ---------------------------
         --------IPHONE VIEW--------
         ---------------------------
         ---------------------------
         ---------------------------
         ---------------------------
         */
        
        if UIDevice.current.localizedModel == "iPhone" {
            
            ZStack {
                Color("DarkGrayBackColor").ignoresSafeArea()
                
                VStack {
                    HStack {
                        Text("     ")
                        Image("FredRest_dark")
                            .resizable()
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("FedExPurpleColor"), lineWidth: 4))
                            .scaledToFit()
                        Text("     ")
                    }
                    
                    Divider()
                    
                    VStack {
                        HStack {
                            Text("Start Time: ")
                                .font(Font.custom("Nunito-Light", size: 27.0))
                                .padding(.leading)
                                .foregroundColor(Color("DullWhiteColor"))
                            Spacer()
                            CustomTextField(
                                        placeholder: Text(" 00:00")
                                            .foregroundColor(Color("TextGrayColor")),
                                        text: $startTime
                                    )
                            .frame(width: 88.0)
                            .keyboardType(.decimalPad)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("DullWhiteColor"), lineWidth: 1))
                            .font(Font.custom("Nunito-Light", size: 30.0))
                            .foregroundColor(Color("OffWhiteColor"))
                            /*Text(" : ")
                                .font(Font.custom("Nunito-Light", size: 27.0))
                                .foregroundColor(Color("DullWhiteColor"))
                            CustomTextField(
                                        placeholder: Text("00")
                                            .foregroundColor(Color("TextGrayColor")),
                                        text: $startMin
                                    )
                            .frame(width: 35.0)
                            .keyboardType(.decimalPad)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("DullWhiteColor"), lineWidth: 1))
                            .font(Font.custom("Nunito-Light", size: 30.0))
                            .foregroundColor(Color("OffWhiteColor"))
                             */
                            Spacer()
                        }
                        
                        HStack {
                            Text("End Time: ")
                                .padding(.leading)
                                .font(Font.custom("Nunito-Light", size: 27.0))
                                .foregroundColor(Color("DullWhiteColor"))
                            Spacer()
                            CustomTextField(
                                        placeholder: Text(" 00:00")
                                            .foregroundColor(Color("TextGrayColor")),
                                        text: $endTime
                                    )
                            .frame(width: 88.0)
                            .keyboardType(.decimalPad)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("DullWhiteColor"), lineWidth: 1))
                            .font(Font.custom("Nunito-Light", size: 30.0))
                            .foregroundColor(Color("OffWhiteColor"))
                            /*Text(" : ")
                                .font(Font.custom("Nunito-Light", size: 27.0))
                                .foregroundColor(Color("DullWhiteColor"))
                            CustomTextField(
                                        placeholder: Text("00")
                                            .foregroundColor(Color("TextGrayColor")),
                                        text: $endMin
                                    )
                            .frame(width: 35.0)
                            .keyboardType(.decimalPad)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("DullWhiteColor"), lineWidth: 1))
                            .font(Font.custom("Nunito-Light", size: 30.0))
                            .foregroundColor(Color("OffWhiteColor"))
                             */
                            Spacer()
                        }
                        
                        HStack {
                            Text("Transition Time: ")
                                .padding(.leading)
                                .font(Font.custom("Nunito-Light", size: 25.0))
                                .foregroundColor(Color("DullWhiteColor"))
                            Spacer()
                            CustomTextField(
                                        placeholder: Text(" 10")
                                            .foregroundColor(Color("TextGrayColor")),
                                        text: $tLen
                                    )
                            .frame(width: 45.0)
                            .keyboardType(.decimalPad)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("DullWhiteColor"), lineWidth: 1))
                            .font(Font.custom("Nunito-Light", size: 30.0))
                            .foregroundColor(Color("OffWhiteColor"))
                            Text("minutes")
                                .font(Font.custom("Nunito-Light", size: 25.0))
                                .foregroundColor(Color("DullWhiteColor"))
                            Spacer()
                        }
                        
                        HStack {
                            Text("Blocks: ")
                                .padding(.leading)
                                .font(Font.custom("Nunito-Light", size: 27.0))
                                .foregroundColor(Color("DullWhiteColor"))
                            
                            Spacer()
                            
                            Picker("Blocks",selection: $numBlocks) {
                                Text("3").tag(3)
                                Text("4").tag(4)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width:240)
                            .clipped()

                            Spacer()
                        }
                        
                        
                        if numBlocks == 4 {
                            
                            VStack {
                                Divider().background(Color.white)
                                VStack {
                                    Text("Block Length Given:")
                                        .font(Font.custom("Nunito-Light", size: 27.0))
                                        .foregroundColor(Color("DullWhiteColor"))
                                    Picker("Given",selection: $given) {
                                        Text("Short").tag(0)
                                        Text("Long").tag(1)
                                        Text("Ratio").tag(2)
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .padding()
                                    .frame(width:380)
                                    .clipped()
                                    
                                }
                                if given == 0 {
                                    HStack {
                                        Text("Short Block:")
                                            .padding(.leading)
                                            .font(Font.custom("Nunito-Light", size: 27.0))
                                            .foregroundColor(Color("DullWhiteColor"))
                                        Spacer()
                                        CustomTextField(
                                                    placeholder: Text("00")
                                                        .foregroundColor(Color("TextGrayColor")),
                                                    text: $shortHr
                                                )
                                        .frame(width: 35.0)
                                        .keyboardType(.decimalPad)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("DullWhiteColor"), lineWidth: 1))
                                        .font(Font.custom("Nunito-Light", size: 30.0))
                                        .foregroundColor(Color("OffWhiteColor"))
                                        Text(" hr  ")
                                            .font(Font.custom("Nunito-Light", size: 27.0))
                                            .foregroundColor(Color("DullWhiteColor"))
                                        CustomTextField(
                                                    placeholder: Text("00")
                                                        .foregroundColor(Color("TextGrayColor")),
                                                    text: $shortMin
                                                )
                                        .frame(width: 35.0)
                                        .keyboardType(.decimalPad)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("DullWhiteColor"), lineWidth: 1))
                                        .font(Font.custom("Nunito-Light", size: 30.0))
                                        .foregroundColor(Color("OffWhiteColor"))
                                        Text(" min")
                                            .font(Font.custom("Nunito-Light", size: 27.0))
                                            .foregroundColor(Color("DullWhiteColor"))
                                        Spacer()
                                    }
                                }
                                if given == 1 {
                                    HStack {
                                        Text("Long Block:")
                                            .padding(.leading)
                                            .font(Font.custom("Nunito-Light", size: 27.0))
                                            .foregroundColor(Color("DullWhiteColor"))
                                        Spacer()
                                        CustomTextField(
                                                    placeholder: Text("00")
                                                        .foregroundColor(Color("TextGrayColor")),
                                                    text: $longHr
                                                )
                                        .frame(width: 35.0)
                                        .keyboardType(.decimalPad)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("DullWhiteColor"), lineWidth: 1))
                                        .font(Font.custom("Nunito-Light", size: 30.0))
                                        .foregroundColor(Color("OffWhiteColor"))
                                        Text(" hr  ")
                                            .font(Font.custom("Nunito-Light", size: 27.0))
                                            .foregroundColor(Color("DullWhiteColor"))
                                        CustomTextField(
                                                    placeholder: Text("00")
                                                        .foregroundColor(Color("TextGrayColor")),
                                                    text: $longMin
                                                )
                                        .frame(width: 35.0)
                                        .keyboardType(.decimalPad)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("DullWhiteColor"), lineWidth: 1))
                                        .font(Font.custom("Nunito-Light", size: 30.0))
                                        .foregroundColor(Color("OffWhiteColor"))
                                        Text(" min")
                                            .font(Font.custom("Nunito-Light", size: 27.0))
                                            .foregroundColor(Color("DullWhiteColor"))
                                        Spacer()
                                    }
                                }
                                if given == 2 {
                                    HStack {
                                        Text("Short = __% of Long:")
                                            .padding(.leading)
                                            .font(Font.custom("Nunito-Light", size: 27.0))
                                            .foregroundColor(Color("DullWhiteColor"))
                                        Spacer()
                                        CustomTextField(
                                                    placeholder: Text("  0")
                                                        .foregroundColor(Color("TextGrayColor")),
                                                    text: $x
                                                )
                                        .frame(width: 35.0)
                                        .keyboardType(.decimalPad)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("DullWhiteColor"), lineWidth: 1))
                                        .font(Font.custom("Nunito-Light", size: 30.0))
                                        .foregroundColor(Color("OffWhiteColor"))
                                        Spacer()
                                    }
                                }
                                Divider().background(Color.white)
                                Text("Long/Short Sequence:")
                                    .font(Font.custom("Nunito-Light", size: 27.0))
                                    .foregroundColor(Color("DullWhiteColor"))
                                Picker("Sequence",selection: $sequence) {
                                    Text("SSLL").tag("SSLL")
                                    Text("LLSS").tag("LLSS")
                                    Text("SLLS").tag("SLLS")
                                    Text("LSSL").tag("LSSL")
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding()
                                .frame(width:380)
                                .clipped()
                            }
                        }
                    }
                
                    Spacer()
                    
                    
                    Button(action: {
                        
                        /*
                         -------------------------
                         -------------------------
                         -------------------------
                         -------------------------
                         ------BUTTON ACTION------
                         -------------------------
                         -------------------------
                         -------------------------
                         -------------------------
                         */
                        
                        //WHEN YOU PRESS BUTTON:
                        
                        //(1) it runs the math to get start/end/length of blocks:
                        
                        //reset allValid
                        allValid = true
                        
                        //make initial inputs into integers
                        
                        /* (Before switching input to 24hr single input)
                        startHrInt = Int(startHr) ?? 0
                        startMinInt = Int(startMin) ?? 0
                        endHrInt = Int(endHr) ?? 0
                        endMinInt = Int(endMin) ?? 0
                         */
                        
                        startTimeInt = Int(startTime) ?? 0
                        endTimeInt = Int(endTime) ?? 0
                        
                        tLenInt = Int(tLen) ?? 10
                        
                        longHrInt = Int(longHr) ?? 0
                        longMinInt = Int(longMin) ?? 0
                        
                        shortHrInt = Int(shortHr) ?? 0
                        shortMinInt = Int(shortMin) ?? 0
                        
                        xDouble = Double(x) ?? 0.00
                        xDouble = xDouble / 100.00
                        
                        //check to see if all inputs are numeric aka valid
                        //let startHrInvalid:Bool = isNotNumeric(a: startHr)
                        //let startMinInvalid:Bool = isNotNumeric(a: startMin)
                        //let endHrInvalid:Bool = isNotNumeric(a: endHr)
                        //let endMinInvalid:Bool = isNotNumeric(a: endMin)
                        let startTimeInvalid:Bool = isNotNumeric(a: startTime)
                        let endTimeInvalid:Bool = isNotNumeric(a: endTime)
                        
                        let tLenInvalid:Bool = isNotNumeric(a: tLen)
                        let shortHrInvalid:Bool = isNotNumeric(a: shortHr)
                        let shortMinInvalid:Bool = isNotNumeric(a: shortMin)
                        let longHrInvalid:Bool = isNotNumeric(a: longHr)
                        let longMinInvalid:Bool = isNotNumeric(a: longMin)
                        let xInvalid:Bool = isNotNumeric(a: x)
                        
                        if startTimeInvalid || endTimeInvalid || tLenInvalid || shortHrInvalid || shortMinInvalid || longHrInvalid || longMinInvalid || xInvalid {
                            
                            allValid = false
                            errorMessage = "Please only input numeric values"
                        }
                        
                        
                        //ensure that selected given is only non-zero optional input in case user changes value of one but decides to select different given afterward
                        //if given == 0 {
                            //short
                            //longHrInt = 0
                            //longMinInt = 0
                            //aInt = 0
                            //bInt = 0
                        //}
                        //else if given == 1 {
                            //long
                            //shortHrInt = 0
                            //shortMinInt = 0
                            //aInt = 0
                            //bInt = 0
                        //}
                        //else {
                            //ratio
                            //longHrInt = 0
                            //longMinInt = 0
                            //shortHrInt = 0
                            //shortMinInt = 0
                        //}
                        
                        //hr2min(starts)
                        let start:Int = twentyFourHr2min(time:startTimeInt)
                        //hr2min(ends)
                        let end:Int = twentyFourHr2min(time:endTimeInt)
                        //getTotalTime
                        let totalTime:Int = getTotalTime(start: start, end: end)
                        
                        //if tLenInt > totalTime, not valid
                        if allValid {
                            let tLenIntx2:Int = 2 * tLenInt
                            if tLenIntx2 > totalTime {
                                allValid = false
                                errorMessage = "Transition period is too large for given start/end times"
                            }
                        }
                        
                        //set up counters to keep track of what to print:
                        ///
                        //keeps track of what block we're on
                        var blockCount:Int = 0
                        
                        //keeps track of start time of block
                        var counter:Double = Double(start)
                        //keeps track of end time of block
                        var countPlusBlock:Double = 0.0
                        
                        //for 3 blocks
                        if numBlocks == 3 {
                            
                            //clear what gets printed in case numBlocks was previously 4
                            schedule[0] = ""
                            schedule[1] = ""
                            schedule[2] = ""
                            schedule[3] = ""
                            schedule[4] = ""
                            schedule[5] = ""
                            schedule[6] = ""
                            schedLine7 = ""
                            
                            //get length of each block
                            let bLen:Double = getBlockLen3(tLen: tLenInt, totalTime: totalTime)
                            
                            //for each of the 3 blocks, calculate and print start and end times
                            for i in 0...2 {
                            //set correct block count to be printed
                                blockCount = i+1
                                //set end time to start time + block length
                                countPlusBlock = counter + bLen;
                                //convert counter to Hr:Min for printing
                                let counterHours:String = min2hr(minsNotRounded: counter)
                                //convert cPB to Hr:Min for printing
                                let cPBHours:String = min2hr(minsNotRounded: countPlusBlock)
                                //set schedule[i] to "Block " + blockCount + ": " + counterHours + "--" + cPBHours
                                //compiler sucks so have to break it up into smaller pieces:
                                let piece1:String = "Block \(blockCount)"
                                let piece2:String = ":     " + counterHours
                                let piece3:String = "--" + cPBHours
                                //ok now for the finale
                                schedule[i] = piece1 + piece2 + piece3
                                //set new start time for next block
                                counter = countPlusBlock + Double(tLenInt)
                            }
                            //convert block length to Hr:Min for printing
                            let bLenHours:String = min2hr(minsNotRounded: bLen)
                            //***Print "Block length: " + bLenHours
                            schedule[4] = "Block length:     " + bLenHours
                            
                            schedLine1 = " "+schedule[0]+" "
                            schedLine2 = " "+schedule[1]+" "
                            schedLine3 = " "+schedule[2]+" "
                            schedLine4 = " "+schedule[3]+" "
                            schedLine5 = " "+schedule[4]+" "
                            schedLine6 = " "+schedule[5]+" "
                        }
                        
                        //for 4 blocks
                        else{
                            
                            //clear what is printed in case numBlocks was previously 3
                            schedule[0] = ""
                            schedule[1] = ""
                            schedule[2] = ""
                            schedule[3] = ""
                            schedule[4] = ""
                            schedule[5] = ""
                            schedule[6] = ""
                            
                            var long:Double = 0
                            var short:Double = 0
                            
                            //if given short
                            if given == 0 {
                                //convert short to mins
                                short = Double(hr2min(hrs: shortHrInt, mins: shortMinInt))
                                //use short to find long in mins
                                long = getLongLen(tLen: tLenInt, totalTime: totalTime, short: short)
                            }
                            //if given long
                            else if given == 1 {
                                //convert long to mins
                                long = Double(hr2min(hrs: longHrInt, mins: longMinInt))
                                //use long to find short in mins
                                short = getShortLen(tLen: tLenInt, totalTime: totalTime, long: long)
                            }
                            //else if given S = xL
                            else {
                                //find long from x
                                long = getLongFromX(x: xDouble, tLen: tLenInt, totalTime: totalTime)
                                //find short from long
                                short = long * xDouble
                            }
                            
                            //ensure long, short, and tLenInt all valid (not too large)
                            if allValid {
                                let tLenIntx3:Int = tLenInt * 3
                                let shortx2:Double = short * 2.0
                                let longx2:Double = long * 2.0
                                
                                if Double(tLenIntx3) + shortx2 > Double(totalTime) {
                                    allValid = false
                                    errorMessage = "Short block length input is too large"
                                }
                                
                                if Double(tLenIntx3) + longx2 > Double(totalTime) {
                                    allValid = false
                                    errorMessage = "Long block length input is too large"
                                }
                                
                                if short > long {
                                    allValid = false
                                    errorMessage = "Short block is longer than long block"
                                }
                            }
                            
                            //for each "S" or "L" in the sequence
                            for char in sequence {
                                //blockCount keeps track of which block we're on
                                blockCount += 1
                                //if next block is a long
                                if char == "L" {
                                    //set end time of block to be start time + length of block
                                    countPlusBlock = counter + long
                                    //convert start and end times to Hr:Min format for printing
                                    let counterHours:String = min2hr(minsNotRounded: counter)
                                    let cPBHours:String = min2hr(minsNotRounded: countPlusBlock)
                                    //set schedule[i] to be "Long Block " + blockCount + ": " + counterHours + "--" + cPBHours
                                    //compiler sucks so break it up again:
                                    let piece1:String = "Block \(blockCount)"
                                    let piece2:String = " (L):     " + counterHours
                                    let piece3:String = "--" + cPBHours
                                    schedule[blockCount - 1] = piece1 + piece2 + piece3
                                    //set new start time for next block
                                    counter = countPlusBlock + Double(tLenInt)
                                }
                                //if next block is a short
                                else {
                                    //set end time of block to be start time + length of block
                                    countPlusBlock = counter + short
                                    //convert start and end times to Hr:Min format for printing
                                    let counterHours:String = min2hr(minsNotRounded: counter)
                                    let cPBHours:String = min2hr(minsNotRounded: countPlusBlock)
                                    //set scheduke[i] to "Short Block " + blockCount + ": " + counterHours + "--" + cPBHours
                                    //compiler sucks so break it up again:
                                    let piece1:String = "Block \(blockCount)"
                                    let piece2:String = " (S):     " + counterHours
                                    let piece3:String = "--" + cPBHours
                                    schedule[blockCount - 1] = piece1 + piece2 + piece3
                                    //set new start time for next block
                                    counter = countPlusBlock + Double(tLenInt)
                                }
                                //convert short and long block lengths from min to Hr:Min for printing
                                let shortHours:String = min2hr(minsNotRounded: short)
                                let longHours:String = min2hr(minsNotRounded: long)
                                //***Print "Short Block Length: " + shortHours
                                schedule[5] = "Short Length:     " + shortHours
                                //***Print "Long Block Length: " + longHours
                                schedule[6] = "Long Length:     " + longHours
                            }
                            
                            schedLine1 = " "+schedule[0]+" "
                            schedLine2 = " "+schedule[1]+" "
                            schedLine3 = " "+schedule[2]+" "
                            schedLine4 = " "+schedule[3]+" "
                            schedLine5 = " "+schedule[4]+" "
                            schedLine6 = " "+schedule[5]+" "
                            schedLine7 = " "+schedule[6]+" "
                        }
                        
                        //if allValid is false, then throw error message
                        if allValid == false {
                            schedLine1 = " "
                            schedLine2 = " "
                            schedLine3 = " " + errorMessage + " "
                            schedLine4 = " "
                            schedLine5 = " "
                            schedLine6 = " "
                            schedLine7 = " "
                        }
                        
                        //(2) it toggles view from home screen to answer slide:
                        
                        self.showingPreview.toggle()
                        
                        
                    }, label: {
                        Text("Calculate")
                            .font(Font.custom("Nunito-Light", size: 27.0))
                            .foregroundColor(Color("OffWhiteColor"))
                            .frame(width: 150.0, height: 50.0)
                            .background(Color("FedExPurpleColor"))
                            .cornerRadius(15.0)
                    })
                    
                    /*
                     --------------------------
                     --------------------------
                     --------------------------
                     --------------------------
                     --------SHEET VIEW--------
                     --------------------------
                     --------------------------
                     --------------------------
                     --------------------------
                     */
                    
                    .sheet(isPresented: $showingPreview) {
                        ZStack {
                            Color("DarkGrayBackColor").ignoresSafeArea()
                            
                            VStack {
                                Spacer()
                                
                                AnswerView(schedLine1: $schedLine1, schedLine2: $schedLine2, schedLine3: $schedLine3, schedLine4: $schedLine4, schedLine5: $schedLine5, schedLine6: $schedLine6, schedLine7: $schedLine7)
                                
                                Divider()
                                Spacer()
                                Button("Close") {
                                    self.showingPreview.toggle()
                                }
                                .padding(.all)
                                .frame(width: 105.0, height: /*@START_MENU_TOKEN@*/50.0/*@END_MENU_TOKEN@*/)
                                .font(Font.custom("Nunito-Light", size: 27.0))
                                .foregroundColor(Color("OffWhiteColor"))
                                .background(Color("FedExPurpleColor"))
                                .cornerRadius(15.0)
                                
                                Spacer()
                            
                            }
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("FedExPurpleColor"), lineWidth: 4))
                        }
                        
                    }
                    
                
                    Spacer()
                }
                
            }.preferredColorScheme(.dark).ignoresSafeArea(.keyboard, edges: .bottom)
            
        }
        
        
        
        
        
        //
        //
        
        
        
        
        else {
            
            //view for ipad users
            /*
             ---------------------------
             ---------------------------
             ---------------------------
             ---------------------------
             ---------IPAD VIEW---------
             ---------------------------
             ---------------------------
             ---------------------------
             ---------------------------
             */
            
            ZStack {
                Color("DarkGrayBackColor").ignoresSafeArea()
                
                VStack {
                    
                    HStack {
                        Text("                         ")
                        Image("FredRest_dark")
                            .resizable()
                            .scaledToFit()
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color("FedExPurpleColor"), lineWidth: 8))
                        Text("                         ")
                    }
                    
                    Divider()
                    
                    VStack {
                        HStack {
                            Text("Start Time: ")
                                .font(.system(size: 50))
                                .padding(.leading)
                                .foregroundColor(Color("DullWhiteColor"))
                            Spacer()
                            
                            CustomTextField(
                                        placeholder: Text("00")
                                            .foregroundColor(Color("TextGrayColor")),
                                        text: $startTime
                                    )
                                .frame(width: 140.0)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 50))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("DullWhiteColor"), lineWidth: 1))
                                .foregroundColor(Color("OffWhiteColor"))
                            /*Text(" : ")
                                .font(.system(size: 50))
                                .foregroundColor(Color("DullWhiteColor"))
                            CustomTextField(
                                        placeholder: Text("00")
                                            .foregroundColor(Color("TextGrayColor")),
                                        text: $startMin
                                    )
                                .frame(width: 70.0)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 50))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("DullWhiteColor"), lineWidth: 1))
                                .foregroundColor(Color("OffWhiteColor"))
                             */
                            Spacer()
                        }
                        
                        HStack {
                            Text("End Time: ")
                                .padding(.leading)
                                .font(.system(size: 50))
                                .foregroundColor(Color("DullWhiteColor"))
                            Spacer()
                            CustomTextField(
                                        placeholder: Text("00")
                                            .foregroundColor(Color("TextGrayColor")),
                                        text: $endTime
                                    )
                                .frame(width: 140.0)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 50))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("DullWhiteColor"), lineWidth: 1))
                                .foregroundColor(Color("OffWhiteColor"))
                            /*Text(" : ")
                                .font(.system(size: 50))
                                .foregroundColor(Color("DullWhiteColor"))
                            CustomTextField(
                                        placeholder: Text("00")
                                            .foregroundColor(Color("TextGrayColor")),
                                        text: $endMin
                                    )
                                .frame(width: 70.0)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 50))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("DullWhiteColor"), lineWidth: 1))
                                .foregroundColor(Color("OffWhiteColor"))
                             */
                            Spacer()
                        }
                        
                        HStack {
                            Text("Transition Time: ")
                                .padding(.leading)
                                .font(.system(size: 50))
                                .foregroundColor(Color("DullWhiteColor"))
                            Spacer()
                            CustomTextField(
                                        placeholder: Text("  0")
                                            .foregroundColor(Color("TextGrayColor")),
                                        text: $tLen
                                    )
                                .frame(width: 70.0)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 50))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("DullWhiteColor"), lineWidth: 1))
                                .foregroundColor(Color("OffWhiteColor"))
                            Text(" minutes")
                                .font(.system(size: 50))
                                .foregroundColor(Color("DullWhiteColor"))
                            Spacer()
                        }
                        
                        HStack {
                            Text("Blocks: ")
                                .padding(.leading)
                                .font(.system(size: 50))
                                .foregroundColor(Color("DullWhiteColor"))
                            
                            Spacer()
                            
                            Picker("Blocks",selection: $numBlocks) {
                                Text("3").tag(3)
                                Text("4").tag(4)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width:400.0)
                            .clipped()
                        
                            Spacer()
                        }
                        
                        
                        if numBlocks == 4 {
                            
                            VStack {
                                Divider().background(Color.white)
                                HStack {
                                    Text("Block Length Given:")
                                        .padding(.leading)
                                        .font(.system(size: 50))
                                        .foregroundColor(Color("DullWhiteColor"))
                                    
                                    Spacer()
                                    
                                    Picker("Given",selection: $given) {
                                        Text("Short").tag(0)
                                        Text("Long").tag(1)
                                        Text("Ratio").tag(2)
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .padding()
                                    .frame(width:400.0)
                                    .clipped()
                                    
                                    Spacer()
                                }
                                
                                if given == 0 {
                                    HStack {
                                        Text("Short Block:")
                                            .padding(.leading)
                                            .font(.system(size: 50))
                                            .foregroundColor(Color("DullWhiteColor"))
                                        Spacer()
                                        CustomTextField(
                                                    placeholder: Text("00")
                                                        .foregroundColor(Color("TextGrayColor")),
                                                    text: $shortHr
                                                )
                                            .frame(width: 70.0)
                                            .keyboardType(.decimalPad)
                                            .font(.system(size: 50))
                                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("DullWhiteColor"), lineWidth: 1))
                                            .foregroundColor(Color("OffWhiteColor"))
                                        Text(" hr   ")
                                            .font(.system(size: 50))
                                            .foregroundColor(Color("DullWhiteColor"))
                                        CustomTextField(
                                                    placeholder: Text("00")
                                                        .foregroundColor(Color("TextGrayColor")),
                                                    text: $shortMin
                                                )
                                            .frame(width: 70.0)
                                            .keyboardType(.decimalPad)
                                            .font(.system(size: 50))
                                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("DullWhiteColor"), lineWidth: 1))
                                            .foregroundColor(Color("OffWhiteColor"))
                                        Text(" min")
                                            .font(.system(size: 50))
                                            .foregroundColor(Color("DullWhiteColor"))
                                        Spacer()
                                    }
                                }
                                if given == 1 {
                                    HStack {
                                        Text("Long Block:")
                                            .padding(.leading)
                                            .font(.system(size: 50))
                                            .foregroundColor(Color("DullWhiteColor"))
                                        Spacer()
                                        CustomTextField(
                                                    placeholder: Text("00")
                                                        .foregroundColor(Color("TextGrayColor")),
                                                    text: $longHr
                                                )
                                            .frame(width: 70.0)
                                            .keyboardType(.decimalPad)
                                            .font(.system(size: 50))
                                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("DullWhiteColor"), lineWidth: 1))
                                            .foregroundColor(Color("OffWhiteColor"))
                                        Text(" hr   ")
                                            .font(.system(size: 50))
                                            .foregroundColor(Color("DullWhiteColor"))
                                        CustomTextField(
                                                    placeholder: Text("00")
                                                        .foregroundColor(Color("TextGrayColor")),
                                                    text: $longMin
                                                )
                                            .frame(width: 70.0)
                                            .keyboardType(.decimalPad)
                                            .font(.system(size: 50))
                                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("DullWhiteColor"), lineWidth: 1))
                                            .foregroundColor(Color("OffWhiteColor"))
                                        Text(" min")
                                            .font(.system(size: 50))
                                            .foregroundColor(Color("DullWhiteColor"))
                                        Spacer()
                                    }
                                }
                                if given == 2 {
                                    HStack {
                                        Text("Short = __% of Long:")
                                            .padding(.leading)
                                            .font(.system(size: 50))
                                            .foregroundColor(Color("DullWhiteColor"))
                                        Spacer()
                                        CustomTextField(
                                                    placeholder: Text("  0")
                                                        .foregroundColor(Color("TextGrayColor")),
                                                    text: $x
                                                )
                                            .frame(width: 70.0)
                                            .keyboardType(.decimalPad)
                                            .font(.system(size: 50))
                                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("DullWhiteColor"), lineWidth: 1))
                                            .foregroundColor(Color("OffWhiteColor"))
                                        
                                        Spacer()
                                    }
                                }
                                Divider().background(Color.white)
                                HStack {
                                    Text("Block Sequence:")
                                        .font(.system(size: 50))
                                        .padding(.leading)
                                        .foregroundColor(Color("DullWhiteColor"))
                                    Spacer()
                                    Picker("Sequence",selection: $sequence) {
                                        Text("SSLL").tag("SSLL")
                                        Text("LLSS").tag("LLSS")
                                        Text("SLLS").tag("SLLS")
                                        Text("LSSL").tag("LSSL")
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .padding()
                                    .frame(width:500)
                                    .clipped()
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                
                    Spacer()
                    
                    
                    Button(action: {
                        
                        /*
                         -------------------------
                         -------------------------
                         -------------------------
                         -------------------------
                         ------BUTTON ACTION------
                         -------------------------
                         -------------------------
                         -------------------------
                         -------------------------
                         */
                        
                        //WHEN YOU PRESS BUTTON:
                        
                        //(1) it runs the math to get start/end/length of blocks:
                        
                        //reset allValid
                        allValid = true
                        
                        //make initial inputs into integers
                        //startHrInt = Int(startHr) ?? 0
                        //startMinInt = Int(startMin) ?? 0
                        //endHrInt = Int(endHr) ?? 0
                        //endMinInt = Int(endMin) ?? 0
                        
                        startTimeInt = Int(startTime) ?? 0
                        endTimeInt = Int(endTime) ?? 0
                        
                        tLenInt = Int(tLen) ?? 10
                        
                        longHrInt = Int(longHr) ?? 0
                        longMinInt = Int(longMin) ?? 0
                        
                        shortHrInt = Int(shortHr) ?? 0
                        shortMinInt = Int(shortMin) ?? 0
                        
                        xDouble = Double(x) ?? 0.00
                        xDouble = xDouble / 100.00
                        
                        //check to see if all inputs are numeric aka valid
                        //let startHrInvalid:Bool = isNotNumeric(a: startHr)
                        //let startMinInvalid:Bool = isNotNumeric(a: startMin)
                        //let endHrInvalid:Bool = isNotNumeric(a: endHr)
                        //let endMinInvalid:Bool = isNotNumeric(a: endMin)
                        let startTimeInvalid:Bool = isNotNumeric(a: startTime)
                        let endTimeInvalid:Bool = isNotNumeric(a: endTime)
                        
                        let tLenInvalid:Bool = isNotNumeric(a: tLen)
                        let shortHrInvalid:Bool = isNotNumeric(a: shortHr)
                        let shortMinInvalid:Bool = isNotNumeric(a: shortMin)
                        let longHrInvalid:Bool = isNotNumeric(a: longHr)
                        let longMinInvalid:Bool = isNotNumeric(a: longMin)
                        let xInvalid:Bool = isNotNumeric(a: x)
                        
                        if startTimeInvalid || endTimeInvalid || tLenInvalid || shortHrInvalid || shortMinInvalid || longHrInvalid || longMinInvalid || xInvalid {
                            
                            allValid = false
                            errorMessage = "Please only input numeric values"
                        }
                        
                        
                        //ensure that selected given is only non-zero optional input in case user changes value of one but decides to select different given afterward
                        //if given == 0 {
                            //short
                            //longHrInt = 0
                            //longMinInt = 0
                            //aInt = 0
                            //bInt = 0
                        //}
                        //else if given == 1 {
                            //long
                            //shortHrInt = 0
                            //shortMinInt = 0
                            //aInt = 0
                            //bInt = 0
                        //}
                        //else {
                            //ratio
                            //longHrInt = 0
                            //longMinInt = 0
                            //shortHrInt = 0
                            //shortMinInt = 0
                        //}
                        
                        //hr2min(starts)
                        let start:Int = twentyFourHr2min(time:startTimeInt)
                        //hr2min(ends)
                        let end:Int = twentyFourHr2min(time:endTimeInt)
                        //getTotalTime
                        let totalTime:Int = getTotalTime(start: start, end: end)
                        
                        //if tLenInt > totalTime, not valid
                        if allValid {
                            let tLenIntx2:Int = 2 * tLenInt
                            if tLenIntx2 > totalTime {
                                allValid = false
                                errorMessage = "Transition period is too large for given start/end times"
                            }
                        }
                        
                        //set up counters to keep track of what to print:
                        ///
                        //keeps track of what block we're on
                        var blockCount:Int = 0
                        
                        //keeps track of start time of block
                        var counter:Double = Double(start)
                        //keeps track of end time of block
                        var countPlusBlock:Double = 0.0
                        
                        //for 3 blocks
                        if numBlocks == 3 {
                            
                            //clear what gets printed in case numBlocks was previously 4
                            schedule[0] = ""
                            schedule[1] = ""
                            schedule[2] = ""
                            schedule[3] = ""
                            schedule[4] = ""
                            schedule[5] = ""
                            schedule[6] = ""
                            schedLine7 = ""
                            
                            //get length of each block
                            let bLen:Double = getBlockLen3(tLen: tLenInt, totalTime: totalTime)
                            
                            //for each of the 3 blocks, calculate and print start and end times
                            for i in 0...2 {
                            //set correct block count to be printed
                                blockCount = i+1
                                //set end time to start time + block length
                                countPlusBlock = counter + bLen;
                                //convert counter to Hr:Min for printing
                                let counterHours:String = min2hr(minsNotRounded: counter)
                                //convert cPB to Hr:Min for printing
                                let cPBHours:String = min2hr(minsNotRounded: countPlusBlock)
                                //set schedule[i] to "Block " + blockCount + ": " + counterHours + "--" + cPBHours
                                //compiler sucks so have to break it up into smaller pieces:
                                let piece1:String = "Block \(blockCount)"
                                let piece2:String = ":     " + counterHours
                                let piece3:String = "--" + cPBHours
                                //ok now for the finale
                                schedule[i] = piece1 + piece2 + piece3
                                //set new start time for next block
                                counter = countPlusBlock + Double(tLenInt)
                            }
                            //convert block length to Hr:Min for printing
                            let bLenHours:String = min2hr(minsNotRounded: bLen)
                            //***Print "Block length: " + bLenHours
                            schedule[4] = "Block length:     " + bLenHours
                            
                            schedLine1 = " "+schedule[0]+" "
                            schedLine2 = " "+schedule[1]+" "
                            schedLine3 = " "+schedule[2]+" "
                            schedLine4 = " "+schedule[3]+" "
                            schedLine5 = " "+schedule[4]+" "
                            schedLine6 = " "+schedule[5]+" "
                        }
                        
                        //for 4 blocks
                        else{
                            
                            //clear what is printed in case numBlocks was previously 3
                            schedule[0] = ""
                            schedule[1] = ""
                            schedule[2] = ""
                            schedule[3] = ""
                            schedule[4] = ""
                            schedule[5] = ""
                            schedule[6] = ""
                            
                            var long:Double = 0
                            var short:Double = 0
                            
                            //if given short
                            if given == 0 {
                                //convert short to mins
                                short = Double(hr2min(hrs: shortHrInt, mins: shortMinInt))
                                //use short to find long in mins
                                long = getLongLen(tLen: tLenInt, totalTime: totalTime, short: short)
                            }
                            //if given long
                            else if given == 1 {
                                //convert long to mins
                                long = Double(hr2min(hrs: longHrInt, mins: longMinInt))
                                //use long to find short in mins
                                short = getShortLen(tLen: tLenInt, totalTime: totalTime, long: long)
                            }
                            //else if given S = xL
                            else {
                                //find long from x
                                long = getLongFromX(x: xDouble, tLen: tLenInt, totalTime: totalTime)
                                //find short from long
                                short = long * xDouble
                            }
                            
                            //ensure long, short, and tLenInt all valid (not too large)
                            if allValid {
                                let tLenIntx3:Int = tLenInt * 3
                                let shortx2:Double = short * 2.0
                                let longx2:Double = long * 2.0
                                
                                if Double(tLenIntx3) + shortx2 > Double(totalTime) {
                                    allValid = false
                                    errorMessage = "Short block length input is too large"
                                }
                                
                                if Double(tLenIntx3) + longx2 > Double(totalTime) {
                                    allValid = false
                                    errorMessage = "Long block length input is too large"
                                }
                                
                                if short > long {
                                    allValid = false
                                    errorMessage = "Short block is longer than long block"
                                }
                            }
                            
                            //for each "S" or "L" in the sequence
                            for char in sequence {
                                //blockCount keeps track of which block we're on
                                blockCount += 1
                                //if next block is a long
                                if char == "L" {
                                    //set end time of block to be start time + length of block
                                    countPlusBlock = counter + long
                                    //convert start and end times to Hr:Min format for printing
                                    let counterHours:String = min2hr(minsNotRounded: counter)
                                    let cPBHours:String = min2hr(minsNotRounded: countPlusBlock)
                                    //set schedule[i] to be "Long Block " + blockCount + ": " + counterHours + "--" + cPBHours
                                    //compiler sucks so break it up again:
                                    let piece1:String = "Block \(blockCount)"
                                    let piece2:String = " (L):     " + counterHours
                                    let piece3:String = "--" + cPBHours
                                    schedule[blockCount - 1] = piece1 + piece2 + piece3
                                    //set new start time for next block
                                    counter = countPlusBlock + Double(tLenInt)
                                }
                                //if next block is a short
                                else {
                                    //set end time of block to be start time + length of block
                                    countPlusBlock = counter + short
                                    //convert start and end times to Hr:Min format for printing
                                    let counterHours:String = min2hr(minsNotRounded: counter)
                                    let cPBHours:String = min2hr(minsNotRounded: countPlusBlock)
                                    //set scheduke[i] to "Short Block " + blockCount + ": " + counterHours + "--" + cPBHours
                                    //compiler sucks so break it up again:
                                    let piece1:String = "Block \(blockCount)"
                                    let piece2:String = " (S):     " + counterHours
                                    let piece3:String = "--" + cPBHours
                                    schedule[blockCount - 1] = piece1 + piece2 + piece3
                                    //set new start time for next block
                                    counter = countPlusBlock + Double(tLenInt)
                                }
                                //convert short and long block lengths from min to Hr:Min for printing
                                let shortHours:String = min2hr(minsNotRounded: short)
                                let longHours:String = min2hr(minsNotRounded: long)
                                //***Print "Short Block Length: " + shortHours
                                schedule[5] = "Short Length:     " + shortHours
                                //***Print "Long Block Length: " + longHours
                                schedule[6] = "Long Length:     " + longHours
                            }
                            
                            schedLine1 = " "+schedule[0]+" "
                            schedLine2 = " "+schedule[1]+" "
                            schedLine3 = " "+schedule[2]+" "
                            schedLine4 = " "+schedule[3]+" "
                            schedLine5 = " "+schedule[4]+" "
                            schedLine6 = " "+schedule[5]+" "
                            schedLine7 = " "+schedule[6]+" "
                        }
                        
                        //if allValid is false, then throw error message
                        if allValid == false {
                            schedLine1 = " "
                            schedLine2 = " "
                            schedLine3 = " " + errorMessage + " "
                            schedLine4 = " "
                            schedLine5 = " "
                            schedLine6 = " "
                            schedLine7 = " "
                        }
                        
                        //(2) it toggles view from home screen to answer slide:
                        
                        self.showingPreview.toggle()
                        
                        
                    }, label: {
                        Text("Calculate")
                            .font(.system(size: 50))
                            .foregroundColor(Color("OffWhiteColor"))
                            .frame(width: 350.0, height: 80.0)
                            .background(Color("FedExPurpleColor"))
                            .cornerRadius(15.0)
                    })
                    
                    /*
                     --------------------------
                     --------------------------
                     --------------------------
                     --------------------------
                     --------SHEET VIEW--------
                     --------------------------
                     --------------------------
                     --------------------------
                     --------------------------
                     */
                    
                    .sheet(isPresented: $showingPreview) {
                        ZStack {
                            Color("DarkGrayBackColor").ignoresSafeArea()
                            
                            VStack {
                                Spacer()
                                
                                AnswerView(schedLine1: $schedLine1, schedLine2: $schedLine2, schedLine3: $schedLine3, schedLine4: $schedLine4, schedLine5: $schedLine5, schedLine6: $schedLine6, schedLine7: $schedLine7)
                                
                                Divider()
                                Spacer()
                                Button("Close") {
                                    self.showingPreview.toggle()
                                }
                                .padding(.all)
                                .frame(width: 250.0, height: 80.0)
                                .font(.system(size: 50))
                                .foregroundColor(Color("OffWhiteColor"))
                                .background(Color("FedExPurpleColor"))
                                .cornerRadius(15.0)
                                
                                Spacer()
                            
                            }.overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("FedExPurpleColor"), lineWidth: 4))
                        }
                        
                    }
                    
                
                    Spacer()
                }//end of V
                
            }.preferredColorScheme(.dark).ignoresSafeArea(.keyboard, edges: .bottom) //end of Z
            
        }//end of ipad
        
        
    }//end of body
    
    /*
     --------------------------
     --------------------------
     --------------------------
     --------------------------
     ------HELPER METHODS------
     --------------------------
     --------------------------
     --------------------------
     --------------------------
     */
    
    //takes hours and minutes, gives total in minutes (int)
    func hr2min(hrs:Int, mins:Int)->Int {
        let hrMins:Int = hrs * 60
        let ans:Int = hrMins + mins
        return ans
    }
    
    //takes start and end 24hr time and puts into minutes (int)
    func twentyFourHr2min(time:Int)->Int {
        let min:Int = time % 100
        let hr = (time - min) / 100
        let hrMins:Int = hr * 60
        return hrMins + min
    }
    
    //takes minutes, gives hr:min (string)
    func min2hr(minsNotRounded:Double)->String {
        let mins:Int = Int(round(minsNotRounded))
        var hrs:Int = mins / 60
        if hrs >= 24 {hrs = hrs % 24}
        let min:Int = mins % 60
        var m:String = String(min)
        var h:String = String(hrs)
        if min < 10 {m = "0" + String(min)}
        if hrs < 10 {h = "0" + String(hrs)}
        
        return h+":"+m
    }
    
    //takes start and end times, calculates difference
    func getTotalTime(start:Int,end:Int)->Int {
        var ans:Int = 0
        if end >= start {
            ans = end - start
        }
        else {
            let anss:Int = 1440 - start
            ans = anss + end
        }
        return ans
    }
    
    //length of blocks for 3 equally long blocks
    func getBlockLen3(tLen:Int,totalTime:Int)->Double {
        let t2:Double = 2.0 * Double(tLen)
        let numerator:Double = Double(totalTime) - t2
        let ans = numerator / 3.0
        return ans
    }
    
    //length of short blocks for 4 block situation
    func getShortLen(tLen:Int,totalTime:Int,long:Double)->Double {
        let t3:Double = 3.0 * Double(tLen)
        let l2:Double = 2.0 * long
        let numerator:Double = Double(totalTime) - t3 - l2
        return numerator / 2.0
    }
    
    //length of long blocks for 4 block situation
    func getLongLen(tLen:Int,totalTime:Int,short:Double)->Double {
        
        let t3:Double = 3.0 * Double(tLen)
        let s2:Double = 2.0 * short
        let numerator:Double = Double(totalTime) - t3 - s2
        return numerator / 2.0
    }
    
    
    func getLongFromX(x:Double,tLen:Int,totalTime:Int)->Double {
        let num:Double = Double(totalTime) - (3.0 * Double(tLen))
        return num/(2.0 * (x + 1.00))
    }
    
    func isNotNumeric(a: String) -> Bool {
        if a == "" {
            return false
        }
        return Int(a) == nil
    }
    
    
}//end of struct



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.dark)
                
                
                
                
        }
    }
}
