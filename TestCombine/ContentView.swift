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
    
    @State private var futureValue = ""
    @State private var futureState = ""

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

    
    var body: some View {
        
        List{
            
            VStack{
                
                HStack{
                    Text("하나의 이벤트 발생 후 종료")
                    Spacer()
                }
                HStack{
                    Button("Future"){ callFuture() }.padding(.trailing, 5)
                    Text("Value : \(futureValue)").padding(.trailing, 5)
                    Text("Sate : \(futureState)").padding(.trailing, 5)
                    Spacer()
                }
                
            }
            
            VStack{
                HStack{
                    Text("하나의 이벤트 발생 후 종료")
                    Spacer()
                }
                
                HStack{
                    Button("Just"){ callJust() }.padding(.trailing, 5)
                    Text("Value : \(justValue)").padding(.trailing, 5)
                    Text("Sate : \(justState)").padding(.trailing, 5)
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
                    Text("Sate : \(publisherState)").padding(.trailing, 5)
                    Spacer()
                }
            
                Spacer()
            }.padding(.leading, 10)
            
            VStack{
                HStack{
                    Text("flatMap")
                    Spacer()
                }
                
                HStack{
                    Button("flatMap"){ callFlatMap() }.padding(.trailing, 5)
                    Text("Value : \(flatMapValue)").padding(.trailing, 5)
                    Text("Sate : \(flatMapState)").padding(.trailing, 5)
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
                    Text("Sate : \(prefixState)").padding(.trailing, 5)
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
                    Text("Sate : \(zipState)").padding(.trailing, 5)
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
                    Text("Sate : \(tryCatchState)").padding(.trailing, 5)
                    Spacer()
                }
            }
            
        }
    
        
    }
    
    
    func callFuture(){
        let cancellable = generateAsyncRandomNumberFromFuture()
            .sink(receiveCompletion: { result in
                futureState = "\(result)"
            }, receiveValue: { number in
                futureValue = "\(number)"
            })
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
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


