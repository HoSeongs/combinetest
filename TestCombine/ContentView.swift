//
//  ContentView.swift
//  TestCombine
//
//  Created by 최호성 on 2022/07/12.
//

import SwiftUI
import Combine


enum SimpleError: Error { case error }

struct ContentView: View {
    
    @State private var justValue = ""
    @State private var justState = ""
    
    @State private var publisherValue = ""
    @State private var publisherState = ""
    
    @State private var flatMapValue = ""
    @State private var flatMapState = ""
    
    @State private var prefixValue = ""
    @State private var prefixState = ""
    
    @State private var zipValue = ""
    @State private var zipState = ""
    
    @State private var tryCatchValue = ""
    @State private var tryCatchState = ""
    
    @State private var sendValue = 1
    @State private var currentSubjectValue = 0
    @State private var currentSubjectState = ""
    
    @State private var sendValue2 = 1
    @State private var passThroughValue = 0
    @State private var passThroughState = ""
    
    @State private var subjectZipValue = ""
    @State private var subjectZipState = ""
    
    var operationQueue = OperationQueue()
    var IMG_URL = "https://picsum.photos/400/400/?random"
    
    init(){
        operationQueue.name = "Thread : (Qos: Default)"
        operationQueue.qualityOfService = .default
    }

    //let cancelBag = CancelBag()
    
    var body: some View {
        List{
            
            Section(header: Text("Publishers")) {
                VStack{
                    HStack{
                        Text("하나의 이벤트 발생 후 종료")
                        Spacer()
                    }
                    
                    HStack{
                        Button("Just"){ callJust() }.padding(.trailing, 5)
                        Text("Value : \(justValue)").padding(.trailing, 5)
                        Text("State : \(justState)").padding(.trailing, 5)
                        Spacer()
                    }
                }
            
            
            
                VStack{
                    
                    HStack{
                        Text("array -> publisher 변환 - array 원소 방출 후 종료")
                        Spacer()
                    }
                    
                    HStack{
                        Button(".publisher"){ asPublisher() }.padding(.trailing, 5)
                        Text("Value : \(publisherValue)").padding(.trailing, 5)
                        Text("State : \(publisherState)").padding(.trailing, 5)
                        Spacer()
                    }
                
                    Spacer()
                }.padding(.leading, 10)
                
                VStack{
                    HStack{
                        Text("flatMap - 문자 Publi를 정수 Publi로")
                        Spacer()
                    }
                    
                    HStack{
                        Button("flatMap"){ callFlatMap() }.padding(.trailing, 5)
                        Text("Value : \(flatMapValue)").padding(.trailing, 5)
                        Text("State : \(flatMapState)").padding(.trailing, 5)
                        Spacer()
                    }
                }
                
                VStack{
                    HStack{
                        Text("Rx의 take와 동일")
                        Spacer()
                    }
                    
                    HStack{
                        Button("prefix"){ callPrefix() }.padding(.trailing, 5)
                        Text("Value : \(prefixValue)").padding(.trailing, 5)
                        Text("State : \(prefixState)").padding(.trailing, 5)
                        Spacer()
                    }
                }
                
                VStack{
                    HStack{
                        Text("Rx의 zip")
                        Spacer()
                    }
                    
                    HStack{
                        Button("zip"){ callZip() }.padding(.trailing, 5)
                        Text("Value : \(zipValue)").padding(.trailing, 5)
                        Text("State : \(zipState)").padding(.trailing, 5)
                        Spacer()
                    }
                }
                
                
                VStack{
                    HStack{
                        Text("Rx의 onErrorReturn")
                        Spacer()
                    }
                    
                    HStack{
                        Button("tryCatch"){ callTryCatch() }.padding(.trailing, 5)
                        Text("Value : \(tryCatchValue)").padding(.trailing, 5)
                        Text("State : \(tryCatchState)").padding(.trailing, 5)
                        Spacer()
                    }
                }
                    
            }
            
            Section(header: Text("Subjects")) {
                
                VStack{
                    HStack{
                        Text("Rx의 BehaviorSubject")
                        Spacer()
                    }
                    
                    HStack{
                        Button("CurrentValueSubject send(\(sendValue))"){ callCurrentValueSubject() }.padding(.trailing, 5)
                        Text("Subscription : \(currentSubjectValue)").padding(.trailing, 5)
                        Text("State : \(currentSubjectState)").padding(.trailing, 5)
                        Spacer()
                    }
                }
                
                VStack{
                    HStack{
                        Text("Rx의 PublishSubject")
                        Spacer()
                    }
                    
                    HStack{
                        Button("PassThroughSubject send(\(sendValue2))"){ callPassThroughSubject() }.padding(.trailing, 5)
                        Text("Subscription : \(passThroughValue)").padding(.trailing, 5)
                        Text("State : \(passThroughState)").padding(.trailing, 5)
                        Spacer()
                    }
                }
                
                VStack{
                    HStack{
                        Text("Rx의 두개의 Subject zip")
                        Spacer()
                    }
                    
                    HStack{
                        Button("Subject zip(int subejct, str subject)"){ callSubjectZip() }.padding(.trailing, 5)
                        Text("Subscription : \(subjectZipValue)").padding(.trailing, 5)
                        Text("State : \(subjectZipState)").padding(.trailing, 5)
                        Spacer()
                    }
                }
                
                VStack{
                    HStack{
                        Text("Rx의 oberveOn()")
                        Spacer()
                    }
                    
                    HStack{
                        Button("recieveOn"){ callRecieveOn() }.padding(.trailing, 5)
                        //Image(uiImage: <#T##UIImage#>)
                        Text("State : \(subjectZipState)").padding(.trailing, 5)
                        Spacer()
                    }
                }
                
            }
        }
    
    }
    


    func generateAsyncRandomNumberFromFuture() -> Future<Int, Never>{
        return Future() { promise in
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    //            let number = Int.random(in: 1...10)
    //            promise(Result.success(number))
    //        }
            promise(.success(1))
            promise(.success(2))
        }
    }

    func callJust(){
        
        let publisher = Just("aaa")
        
        let subscriber = publisher.sink { result in
            switch result{
            case .finished:
                justState = "finished"
            case .failure(let error):
                justState = error.localizedDescription
            }
        } receiveValue: { value in
            justValue = value
        }

    }
    
    func asPublisher(){
        
        let publisher = ["a", "b", "c", "d"].publisher
        
        publisher.sink { result in
            switch result{
            case .finished:
                publisherState = "finished"
            case .failure(let error):
                publisherState = "\(error.localizedDescription)"
                
            }
        } receiveValue: { value in
            publisherValue = value
        }

    }
    
    func callFlatMap(){
        
        "a".publisher
            .flatMap { value in ["1", "2"].publisher }
            .sink { result in
                switch result {
                case .finished:
                    flatMapState = "\(result)"
                case .failure(let error):
                    flatMapState = "\(error.localizedDescription)"
                }
            } receiveValue: { value in
                flatMapValue = "\(flatMapValue) \\ \(value)"
            }
    }
    
    func callPrefix(){
        (0...10).publisher
            .prefix(3)
            .sink { result in
                switch result {
                case .finished:
                    prefixState = "finished"
                case .failure(let error):
                    prefixState = "\(error.localizedDescription)"
                }
            } receiveValue: { value in
                prefixValue = "\(prefixValue)_\(value)"
            }
    }
    
    func callZip(){
        
        let cancellable = (0...10).publisher
            .zip(["a", "b", "c"].publisher)
            .sink { result in
                switch result {
                case .finished:
                    zipState = "finished"
                case .failure(let error):
                    zipState = "\(error.localizedDescription)"
                }
            } receiveValue: { (first, second) in
                zipValue = "\(zipValue)_\(first)\(second)"
            }
        
    }
    
    func callTryCatch(){
        
        var numbers = [5, 4, 3, 2, 1, -1, 7, 8, 9, 10]
        
        let cancellable = numbers.publisher
            .tryMap { v in
                if v > 0 {
                    return v
                }else {
                    throw SimpleError.error
                }
            }
            .tryCatch { error in
                Just(0) //발생 후 finished
            }.sink { result in
                switch result {
                case .finished:
                    tryCatchState = "finished"
                case .failure(let error):
                    tryCatchState = "\(error.localizedDescription)"
                }
            } receiveValue: { value in
                tryCatchValue = "\(tryCatchValue)_\(value)"
            }
    }
    
    let currentSubject = CurrentValueSubject<Int, Never>(1)
    func callCurrentValueSubject(){
        
        currentSubject.send(sendValue)
        sendValue += 1
        
        let cancellable = currentSubject.sink { result in
            switch result {
            case .finished:
                currentSubjectState = "finished"
            case .failure(let never):
                currentSubjectState = "실패"
            }
        } receiveValue: { value in
            currentSubjectValue = value
        }

    }
    
    func callPassThroughSubject(){
        
        let passThroughSubject = PassthroughSubject<Int, Never>()
        
        let cancellable = passThroughSubject.sink { result in
            switch result {
            case .finished:
                passThroughState = "finished"
            case .failure(let never):
                passThroughState = "실패"
            }
        } receiveValue: { value in
            passThroughValue = value
        }
        
        //send 시점에 subscriver가 없으면 drop 한다.
        passThroughSubject.send(sendValue2)
        sendValue2 += 1
    }
    
    func callSubjectZip(){
//        let firstSubject = PassthroughSubject<Int, Never>()
//        let secondSubject = PassthroughSubject<String, Never>()
        
        let runLoop = RunLoop.main
        
        runLoop.schedule(after: runLoop.now,
                         interval: .seconds(1),
                         tolerance: .milliseconds(100)) {
            print("Timer fired")
        }//.store
        
    }
    
    func currentThreadName() -> String{
        return OperationQueue.current?.name ?? "Unknown Thread"
    }
    
    func callRecieveOn(){
        Just(IMG_URL)
            .handleEvents(receiveOutput: { _ in print("[1]: \(currentThreadName())")})
            .map{ URL(string: $0)! }
            .tryMap{ try Data(contentsOf: $0)}
            .map{ UIImage(data: $0)}
            .handleEvents(receiveOutput: { _ in print("[2]: \(currentThreadName())")})
            .replaceError(with: nil)
            //.assign(to: \.image, on: imageView)
            //.cancel(with: cancelBag)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


