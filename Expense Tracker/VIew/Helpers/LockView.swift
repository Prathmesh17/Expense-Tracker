//
//  LockView.swift
//  Expense Tracker
//
//  Created by Prathmesh Parteki on 23/09/24.
//

import SwiftUI
import LocalAuthentication

struct LockView<Content : View>: View {
    ///Lock Properties
    var lockType : LockType
    var lockPin : String
    var isEnabled : Bool
    var lockWhenAppGoesBackGround : Bool = true
    @ViewBuilder var content : Content
    var forgotPin : () -> () = { }
    
    ///View properties
    @State private var pin : String = ""
    @State private var animateField : Bool = false
    @State private var isUnlocked : Bool = false
    @State private var noBiometricAccess : Bool = false
    ///Lock Context
    let context = LAContext()
    ///Scene Phase
    @Environment(\.scenePhase) private var phase

    var body: some View {
        GeometryReader {
            let size = $0.size
            
            content
                .frame(width: size.width,height: size.height)
            
            if isEnabled  && !isUnlocked {
                ZStack {
                    
                    Rectangle()
                        .fill(.black)
                        .ignoresSafeArea()
                    
                    if (lockType == .both && !noBiometricAccess) || lockType == .biometric {
                        Group {
                            if noBiometricAccess {
                                Text("Enable biometric authentication in settings to unlock the view.")
                                    .font(.callout)
                                    .multilineTextAlignment(.center)
                                    .padding(50)
                            }else {
                                ///Biometric  / Pin unlock
                                VStack(spacing: 12) {
                                    VStack(spacing : 6) {
                                        Image(systemName: "lock")
                                            .font(.largeTitle)
                                        
                                        Text("Tap to Unlock")
                                            .font(.caption2)
                                            .foregroundStyle(.gray)
                                    }
                                    .frame(width: 100, height: 100)
                                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 10))
                                    .contentShape(.rect)
                                    .onTapGesture {
                                        unLockView()
                                    }
                                    
                                    if lockType == .both {
                                        Text("Enter Pin")
                                            .frame(width: 100,height: 40)
                                            .background(.ultraThinMaterial,in: .rect(cornerRadius: 10))
                                            .contentShape(.rect)
                                            .onTapGesture {
                                                noBiometricAccess = true
                                            }
                                    }
                                }
                            }
                        }
                    }else {
                        ///Custom Number Pad to type View Lock Pin
                        NumberPadPinView()
                    }
                }
                .environment(\.colorScheme,.dark)
                .transition(.offset(y: size.height + 100))
            }
        }
        .onChange(of: isEnabled,initial: true) { oldValue, newValue in
            if newValue {
                unLockView()
            }
        }
        ///Locking when app goes on Background
        .onChange(of: phase) { oldValue, newValue in
            if newValue != .active && lockWhenAppGoesBackGround {
                isUnlocked = false
                pin  = ""
            }
        }
    }
    
    private func unLockView() {
        ///checking and unlocking View
        Task {
            if isBiometricAvailable && lockType != .number {
                ///Requesting Biometric Unlock
                if let result = try? await
                    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock the view"), result {
                    print("Unlocked")
                    withAnimation(.snappy,completionCriteria: .logicallyComplete) {
                        isUnlocked = true
                    } completion: {
                        pin = ""
                    }
                }
            }
            
            ///No Bio Metric Permission || Lock Type Must be Set as Keypad
            ///Updating Biometric Status
            noBiometricAccess = !isBiometricAvailable
        }
    }
    
    private var isBiometricAvailable : Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    ///Numberpad pin View
    @ViewBuilder
    private func NumberPadPinView() -> some View {
        VStack(spacing: 15) {
            Text("Enter Pin")
                .font(.title.bold())
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    ///Back Button only for both type
                    if lockType == .both  && isBiometricAvailable{
                        Button(action: {
                            pin = ""
                            noBiometricAccess = false
                        },label: {
                            Image(systemName: "arrow.left")
                                .font(.title3)
                                .contentShape(.rect)
                        })
                        .tint(.white)
                        .padding(.leading)
                    }
                }
            
            HStack(spacing: 10) {
                ForEach((0..<4), id:\.self) { index in
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 50, height: 55)
                        ///Showing pin at each box with the help of index
                        .overlay {
                            ///Safe Check
                            if pin.count > index {
                                let index = pin.index(pin.startIndex,offsetBy: index)
                                let string = String(pin[index])
                                
                                Text(string)
                                    .font(.title.bold())
                                    .foregroundStyle(.black)
                            }
                        }
                }
            }
            .keyframeAnimator(initialValue: CGFloat.zero, trigger: animateField, content: { content, value in
                content
                    .offset(x: value)
            }, keyframes: { _ in
                KeyframeTrack {
                    CubicKeyframe(30,duration: 0.07)
                    CubicKeyframe(-30,duration: 0.07)
                    CubicKeyframe(20,duration: 0.07)
                    CubicKeyframe(-20,duration: 0.07)
                    CubicKeyframe(0,duration: 0.07)
                }
            })
            .padding(.top, 15)
            .overlay(alignment: .bottomTrailing) {
                Button("Forgot Pin?",action: forgotPin)
                    .foregroundStyle(.white)
                    .offset(y: 40)
            }
            .frame(maxHeight: .infinity)
            
            ///Custom Number Pad
            GeometryReader { _ in
                LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                    ForEach(1...9,id: \.self) {number in
                        Button(action: {
                            ///Adding number to Pin
                            ///Max limit - 4
                            if pin.count < 4 {
                                pin.append("\(number)")
                            }
                        }) {
                            Text("\(number)")
                                .font(.title)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .contentShape(.rect)
                            
                        }
                        .tint(.white)
                    }
                    /// 0 and baclk Button
                    Button(action: {
                        if pin.isEmpty {
                            pin.removeLast()
                        }
                    }) {
                        Image(systemName: "delete.backward")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .contentShape(.rect)
                        
                    }
                    .tint(.white)
                    
                    Button(action: {
                        if pin.count < 4 {
                            pin.append("0")
                        }
                    }) {
                        Text("0")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .contentShape(.rect)
                        
                    }
                    .tint(.white)
                }
                .frame(maxHeight: .infinity,alignment: .bottom)
            }
            .onChange(of: pin) { oldValue, newValue in
                if newValue.count == 4 {
                    ///Validate Pin
                    if lockPin == pin {
//                        print("UnLocked")
                        withAnimation(.snappy,completionCriteria: .logicallyComplete) {
                            isUnlocked = true
                        } completion : {
                            //Clearing Pin
                            pin = ""
                            noBiometricAccess = !isBiometricAvailable
                        }
                    }else {
//                        print("Wrong Pin")
                        pin = ""
                        animateField.toggle()
                    }
                }
            }
        }
        .padding()
        .environment(\.colorScheme,.dark)
    }
    ///Lock Type
    enum LockType : String {
        case biometric = "Bio Metric Auth"
        case number = "Custom Number Lock"
        case both = "First preference will be biometric, and if it's not available, it will go for number lock."
    }
}

#Preview {
    ContentView()
}
