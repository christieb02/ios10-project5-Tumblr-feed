//
//  ViewController.swift
//  ios101-project5-tumbler
//

import UIKit
import Nuke


class ViewController: UIViewController, UITableViewDataSource {
    
    private var posts : [Post] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell

        // Get the post from your array of posts
        let post = posts[indexPath.row]

        // Check if there are any photos in the post
        if let photo = post.photos.first {

            // Create a URL from the photo's URL
            let imageUrl = photo.originalSize.url

            // Use Nuke to load the image from the URL into the image view
            Nuke.loadImage(with: imageUrl, into: cell.posterImageView)
        }

        // Set other cell properties...

        cell.titleLabel.text = post.summary
//        cell.overviewLabel.text = post.caption

        return cell
    }
    

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self

        fetchPosts()
    }



    func fetchPosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        let session = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }

            guard let data = data else {
                print("❌ Data is NIL")
                return
            }

            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)

                DispatchQueue.main.async {
                    self?.posts = blog.response.posts
                    self?.tableView.reloadData()
                    print("✅ We got \(self?.posts.count ?? 0) posts!")
                }

            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
}
