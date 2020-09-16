//
//  ContentView.swift
//  Grids Columns
//
//  Created by Admin on 9/14/20.
//

import SwiftUI

//{
//   "feed":{
//   "title":"Popular Apps \u0026 Games",
//   "id":"https://rss.itunes.appps/new-apps-we-love/all/100/explicit.json",
//      "author":{
//         "name":"iTunes Store",
//         "uri":"http://wwww.apple.com/us/itunes/"
//      },
//      "links":[
//         {
//                  "self":"https://rss.ituneapi/us/ios-apps/new-apps-we-love/all/100/explicit.json"
//         },
//         {
//                 "alternate":"https://itunes.applbj/MZStorwoa/wa/viewRoom?fcId=1253709508"
//         }
//      ],
//      "copyright":"Copyright © 2018 Apple Inc. All rights reserved.",
//      "country":"us",
//      "icon":"http://itunes.apple.com/favicon.ico",
//      "updated":"2020-09-13T02:05:29.000-07:00",
//      "results":[
//         {
//            "artistName":"WarnerMedia",
//            "id":"971265422",
//            "releaseDate":"2015-04-07",
//            "name":"HBO Max: Stream TV \u0026 Movies",
//            "kind":"iosSoftware",
//            "copyright":"© 2020 WarnerMedia Direct, LLC. All Rights Reserved.",
//            "artistId":"1514826633",
//             "artistUrl":"https://apps.apple.com/us/developer/warnermedia/id1514826633",
//             "artworkUrl100":"https://is5-ss0434186_U002c0-512MB-85-220-0-0.png/200x200bb.png",
//            "genres":[
//               {
//                  "genreId":"6016",
//                  "name":"Entertainment",
//                  "url":"https://itunes.apple.com/us/genre/id6016"
//               },

struct RSS: Decodable {
    let feed: Feed
}

struct Feed: Decodable {
    let results: [Result]
}

struct Result: Decodable, Hashable {
    let copyright: String
    let name: String
    let artworkUrl100: String
    let releaseDate: String
}

class GridViewModel: ObservableObject {
    
    @Published var items = 0..<5
    @Published var results = [Result]()
    
    init() {
        // JSON decoding simulation
        //        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (_) in
        //            self.items = 0..<15
        //        }
        
        
        guard let url = URL(string: "https://rss.itunes.apple.com/api/v1/us/ios-apps/new-apps-we-love/all/100/explicit.json") else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // check response status and error
            guard let data = data else { return }
            do {
                let rss = try JSONDecoder().decode(RSS.self, from: data)
                print(rss)
                self.results = rss.feed.results
            } catch {
                print("Failed to decode: \(error)")
            }
        }.resume()
    }
}

import KingfisherSwiftUI

struct ContentView: View {
    
    @ObservedObject var vm = GridViewModel()
   
    @State var searchText = ""
    @State var isSearching = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                SearchBar(searchText: $searchText, isSearching: $isSearching)
                    .padding(.top, 15)
                    .padding(.bottom, 15)
                
                LazyVGrid(columns: [
                    GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16, alignment: .top),
                    GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16, alignment: .top),
                    GridItem(.flexible(minimum: 50, maximum: 200), spacing: 16),
                ], alignment: .leading, spacing: 16, content: {
                    ForEach((vm.results).filter({ "\($0)".contains(searchText) || searchText.isEmpty }), id: \.self) { app in
                        AppInfo(app: app)
                    }
                })
                .padding(.horizontal, 12)
            }
            .navigationTitle("Grid Search")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AppInfo: View {
    
    let app: Result
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            KFImage(URL(string: app.artworkUrl100))
                .resizable()
                .scaledToFit()
                .cornerRadius(22)
            
            Text(app.name)
                .font(.system(size: 10, weight: .semibold))
                .padding(.top, 4)
            
            Text(app.releaseDate)
                .font(.system(size: 9, weight: .regular))
            
            Text(app.copyright)
                .foregroundColor(.gray)
                .font(.system(size: 9, weight: .regular))
            
            Spacer()
        }
    }
}


struct SearchBar: View {
    
    @Binding var searchText: String
    @Binding var isSearching: Bool
    
    var body: some View {
        HStack {
            HStack {
                TextField("Search terms here", text: $searchText)
                    .padding(.leading, 25)
            }
            .padding()
            .background(Color(.systemGray5))
            .cornerRadius(12)
            .padding(.horizontal)
            .onTapGesture {
                isSearching = true
            }
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                    Spacer()
                    
                    if isSearching {
                        Button(action: { searchText = "" }, label: {
                            Image(systemName: "xmark.circle.fill")
                                .padding(.vertical)
                        })
                    }
                }
                .padding(.horizontal, 32)
                .foregroundColor(.gray)
            )
            .transition(.move(edge: .trailing))
            .animation(.spring())
            
            if isSearching {
                Button(action: {
                    isSearching = false
                    searchText = ""
                    
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    
                }, label: {
                    Text("Cancel")
                        .padding(.trailing)
                        .padding(.leading, -12)
                })
                .transition(.move(edge: .trailing))
                .animation(.spring())
            }
        }
    }
}

