//
//  ContentView.swift
//  TestCombine
//
//  Created by 최호성 on 2022/07/12.
//

import SwiftUI
import Combine

struct ContentView: View {
    var body: some View {
        VStack{
            Button("Future"){ callFuture() }
            Button("Just"){ callJust() }
        }
        
    }
}

func callFuture(){
    let cancellable = generateAsyncRandomNumberFromFuture()
        .sink { number in
            print("Got random number \(number).")
        }
}

func generateAsyncRandomNumberFromFuture() -> Future<Int, Never>{
    return Future() { promise in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let number = Int.random(in: 1...10)
            promise(Result.success(number))
        }
        
    }
}

func callJust(){
    
//    let publisher = Just("aaa")
    let publisher = ["aaa", "bbb", "ccc"].publisher
    
    let subscriber = publisher.sink { result in
        switch result{
        case .finished:
            print("finished")
        case .failure(let error):
            print(error.localizedDescription)
        }
    } receiveValue: { value in
        print(value)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
