//
//  NetworkManager.swift
//  LiveKitExample
//
//  Created by Kyaw Naing Tun on 11/09/2022.
//

import Foundation

enum APIError:Error{
    case responseProblem
    case decodingProblem
    case otherProblem
    case encodingProblem
}

struct CallMakingForm: Codable{
    let caller_id: String
    let contact_id: String
}
struct CallMakingData: Codable{
    let room_token: String
}

class NetworkManager {
    
    let baseUrl = "https://webrtcapi.naylinaung.asia/"
    
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    init() {
        // int process here
    }
    
    func createRoomToken(_ formData: RoomTokenForm, completion: @escaping(Result<RoomTokenData, APIError>) -> Void) {
        let resourceString = "\(baseUrl)test/create_token"
        guard let resourseUrl = URL(string: resourceString) else {fatalError()}
        
        do {
            var urlRequest = URLRequest(url: resourseUrl)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(formData)
            
            let task = URLSession.shared.dataTask(with: urlRequest) { [self] (data, response, error) in
                if let error = error {
                    print("Error took place \(error)")
                    completion(.failure(.responseProblem))
                    return
                }
                guard let jsonData = data else {return}
                
                do {
                    let result = try self.decoder.decode(RoomTokenData.self, from: jsonData)
                    print("Response data:\n \(result)")
                    completion(.success(result))
                } catch let jsonErr{
                    print(jsonErr)
                    completion(.failure(.decodingProblem))
                }
                        
            }
            
            task.resume()
            
        } catch {
            completion(.failure(.encodingProblem))
        }
    }
    
    func makeACall(_ formData: CallMakingForm, completion: @escaping(Result<CallMakingData, APIError>) -> Void) {
        let resourceString = "\(baseUrl)call_contact"
        guard let resourseUrl = URL(string: resourceString) else {fatalError()}
        
        do {
            var urlRequest = URLRequest(url: resourseUrl)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(formData)
            
            let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if let error = error {
                    print("Error took place \(error)")
                    completion(.failure(.responseProblem))
                    return
                }
                guard let jsonData = data else {return}
                
                do {
                    let result = try self.decoder.decode(CallMakingData.self, from: jsonData)
                    print("Response data:\n \(result)")
                    completion(.success(result))
                } catch let jsonErr{
                    print(jsonErr)
                    completion(.failure(.decodingProblem))
                }
                        
            }
            
            task.resume()
            
        } catch {
            completion(.failure(.encodingProblem))
        }
    }
    
    func getContacts(completion: @escaping(Result<[Contact], APIError>) -> Void) {
        let resourceString = "\(baseUrl)contacts"
        guard let resourseUrl = URL(string: resourceString) else {fatalError()}
        
        do {
            var urlRequest = URLRequest(url: resourseUrl)
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if let error = error {
                    print("Error took place \(error)")
                    completion(.failure(.responseProblem))
                    return
                }
                guard let jsonData = data else {return}
                
                do {
                    let result = try self.decoder.decode(ContactList.self, from: jsonData)
                    print("Response data:\n \(result)")
                    completion(.success(result.data))
                } catch let jsonErr{
                    print(jsonErr)
                    completion(.failure(.decodingProblem))
                }
                        
            }
            
            task.resume()
            
        } catch {
            completion(.failure(.encodingProblem))
        }
    }
}
