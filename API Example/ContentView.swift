//
//  ContentView.swift
//  API Example
//
//  Created by Lorenzo Murillo IV on 5/12/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var user: GitHubUser?
    
    var body: some View {
        VStack(spacing: 20) {
            
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) {
                image in image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
            }.frame(width: 120, height: 120)
            
            Text(user?.login ?? "Login Placeholder")
                .bold()
                .font(.title3)
            Text(user?.bio ?? "Bio Placeholder")
                .padding()
            Spacer()
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch GHError.invalidURL {
                print("invalid url")
            } catch GHError.invalidResponse{
                print("invalid response")
            } catch GHError.invalidData{
                print("invalid data")
            } catch {
                print("unexpected error")
            }
        }
    }
    
    func getUser() async throws -> GitHubUser {
        let endpoint = "http:api.github.com/users/LorenzoMiv"
        
        //URLs require unwrapping
        guard let url = URL(string: endpoint) else{
            throw GHError.invalidURL
        }
        
        //data: JSON Data that we will be getting
        //response: response codes
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        do{
            let decoder = JSONDecoder()
            decoder .keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch{
            throw GHError.invalidData
        }
    }
}

#Preview {
    ContentView()
}

struct GitHubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio : String
}

enum GHError: Error {
    case invalidData
    case invalidResponse
    case invalidURL
}
