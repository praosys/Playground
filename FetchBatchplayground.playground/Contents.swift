//  Understanding Batch fetch using 3 different ways
//
//  Created by Prasanna Rao.
//

import Foundation

struct File : Codable {
    let id: Int?
}

enum FileFetchError: Error {
    case invalidURL, invalidData, statusCodeNot200, fetchError(Error), unknown
}

extension String {
//    static let fetchFileEndpooint = "https://fileholder.com/file/id/"
    static let fetchFileEndpooint = "https://api.github.com/users/"
}
 
protocol IndividualFileFetcherProtocol {
    func fetchResultSet(fileId: Int, completion: @escaping (Result<File, FileFetchError>) -> ())
    func fetch(fileId: Int, completion: @escaping (File?, FileFetchError?) -> ())
    func fetchAsyncAwait(fileId: Int) async throws -> File
}

class FetchIndividualFile: IndividualFileFetcherProtocol {
    
    func fetchResultSet(fileId: Int, completion: @escaping (Result<File, FileFetchError>) -> ()) {
        guard let url = URL(string: .fetchFileEndpooint + String(fileId)) else {
            completion(.failure(.invalidURL))
            return
        }
                
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(.fetchError(error)))
                return
            }
            guard let data = data, let file = try? JSONDecoder().decode(File.self, from: data) else {
                completion(.failure(.invalidData))
                return
            }

            completion(.success(file))
            return
        }
        task.resume()
    }
    
    func fetch(fileId: Int, completion: @escaping (File?, FileFetchError?) -> ()) {
        guard let url = URL(string: .fetchFileEndpooint + String(fileId)) else {
            completion(nil, .invalidURL)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(nil, .fetchError(error))
                return
            }
            guard let data = data, let file = try? JSONDecoder().decode(File.self, from: data) else {
                completion(nil, .invalidData)
                return
            }

            completion(file, nil)
            return
        }
        task.resume()
    }
    
    func fetchAsyncAwait(fileId: Int) async throws -> File {
        guard let url = URL(string: .fetchFileEndpooint + String(fileId)) else {
            throw FileFetchError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpUrlResponse = response as? HTTPURLResponse, httpUrlResponse.statusCode != 200 {
            throw FileFetchError.statusCodeNot200
        }
        
        do {
            let file = try JSONDecoder().decode(File.self, from: data)
            return file
        } catch {
            throw FileFetchError.invalidData
        }
    }
}

// **********************************************************
print("Batch processing now.......\n")
// **********************************************************

protocol BatchFileFetcherProtocol {
    func fetchFilesResultSet(fileIds: [Int], completion: @escaping (Result<[File],FileFetchError>) -> ())
    func fetchFiles(fileIds: [Int], completion: @escaping ([File]) -> ())
    func fetchFilesAsyncAwait(fileIds: [Int]) async throws -> [File]
}
 
class BatchFilesFetcher: BatchFileFetcherProtocol {
    
    let individualFileFetcher: IndividualFileFetcherProtocol?
    
    init(individualFileFetcher: IndividualFileFetcherProtocol?) {
        self.individualFileFetcher = individualFileFetcher
    }
    
    func fetchFilesResultSet(fileIds: [Int], completion: @escaping (Result<[File], FileFetchError>) -> ()) {
        var allFiles: [File] = []
        allFiles.reserveCapacity(fileIds.count)
        let dispatchQueue = DispatchQueue(label: "my.dispatch.queue", attributes: .concurrent)
        let dispatchGroup = DispatchGroup()

        fileIds.forEach { aFileId in
            dispatchGroup.enter()
            
            individualFileFetcher?.fetchResultSet(fileId: aFileId, completion: { result in
                switch result {
                case .success(let file):
                    dispatchQueue.async {
                        allFiles.append(file)
                        dispatchGroup.leave()
                    }
                case .failure(let error):
                    dispatchQueue.async {
                        debugPrint("Individual file failure logic need to be implemented as per requirements, error = \(error)")
                        dispatchGroup.leave()
                    }
                }
                
            })
        }
        
        dispatchGroup.notify(queue: .global()) {
            completion(.success(allFiles))
        }
    }
                
    func fetchFiles(fileIds: [Int], completion: @escaping ([File]) -> ()) {
        var allFiles: [File] = []
        allFiles.reserveCapacity(fileIds.count)
        let dispatchQueue = DispatchQueue(label: "my.dispatch.queue", attributes: .concurrent)
        let dispatchGroup = DispatchGroup()
        
        fileIds.forEach { fileId in
            dispatchGroup.enter()
            
            individualFileFetcher?.fetch(fileId: fileId) { (file, fileFetchError) in
                if let file = file {
                    dispatchQueue.async {
                        allFiles.append(file)
                        dispatchGroup.leave()
                    }
                } else if let fileError = fileFetchError {
                    // No action done, can implement own logic
                    print("2. Received Error in fetchFiles for Id \(fileId), error = \(fileError)")
                    dispatchQueue.async {
                        dispatchGroup.leave()
                    }
                }
                
            }
        }
        
        dispatchGroup.notify(queue: .global()) {
            completion(allFiles)
        }
    }
         
    func fetchFilesAsyncAwait(fileIds: [Int]) async throws -> [File] {
        guard let individualFileFetcher = individualFileFetcher else {
            throw FileFetchError.unknown // Throw appropriate error
        }
        
        return try await withThrowingTaskGroup(of: File.self) { group in
            var allFiles: [File] = []
            allFiles.reserveCapacity(fileIds.count)
            
            for id in fileIds {
                group.addTask {
                    return try await individualFileFetcher.fetchAsyncAwait(fileId: id)
                }
            }
            
            for try await afile in group {
                allFiles.append(afile)
            }
            
            return allFiles
        }
    }

}

let individualFileFetcher: IndividualFileFetcherProtocol? = FetchIndividualFile()
let batchFilesFetcher: BatchFileFetcherProtocol = BatchFilesFetcher(individualFileFetcher: individualFileFetcher)

// fetchFilesResultSet(fileIds: [Int], completion: @escaping (Result<[File], FileFetchError>) -> ())
batchFilesFetcher.fetchFilesResultSet(fileIds: [1,2,3,4]) { result in
    switch result {
    case .success(let allFiles):
        print("1. BatchFilesFetcher.fetchFilesResultSet, files =")
        allFiles.forEach { file in
            print(file)
        }
    case .failure:
        print("2. BatchFilesFetcher.fetchFilesResultSet, Failure (Errors) need to be implemented")
    }
}

// fetchFiles(fileIds: [Int], completion: @escaping ([File]) -> ())
batchFilesFetcher.fetchFiles(fileIds: [3,4,5,6]) { allFiles in
    print("\n2. BatchFilesFetcher.fetchFiles, files =")
    allFiles.forEach { file in
        print(file)
    }
}

//  fetchFilesAsyncAwait(fileIds: [Int]) async throws -> [File]
Task {
    do {
        let allFiles = try await batchFilesFetcher.fetchFilesAsyncAwait(fileIds: [5,6,7,8,9,10])
        print("\n3. BatchFilesFetcher.fetchFilesAsyncAwait, files =")
        allFiles.forEach { file in
            print(file)
        }
    } catch {
        print("3. BatchFilesFetcher.fetchFilesAsyncAwait, Catch can be implemented properly")
    }
}
