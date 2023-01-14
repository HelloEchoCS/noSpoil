# NoSpoil: a simple household food inventory management application
Ever forget something at the corner of your fridge until it smells? This app can track the Best Before Date for your food inventories, and help reduce the chance of food waste.

## Features
- User authentication
- Create and manage product categories
- Create and manage stock items under each product category
- Quickly glance food items that are expired, due today, or about to expire within 5 days
- Quickly consume or spoil an item
- Track food spoil rate for each product category, try to reduce it as much as you can!
- Responsive & Dark mode by design :)

## General application information
- Ruby version: 3.1.1
- Tested on Firefox 102.0 and Chrome 103.0.5060.134
- PostgreSQL version: 14.4

## Getting Started
Make sure specified Ruby and PostgreSQL versions are installed and correctly configured.

Navigate to the project root folder and install dependencies:
```shell
bundle install
```

To initialize the database, run
```shell
createdb ns_db
```

Import seed data:
```shell
psql ns_db < ./data/db_dump.sql
```

Finally, start the app by running:
```shell
ruby app.rb
```
Now open the browser and visit `localhost:4567`, you should be greeted by the Sign In page.

To log in, you can either create a new user, or use admin/admin for username/password.

## Design Choices

- Sign-in state validation

  I choose to match client's `session_id` with the database's for each request, instead of simply checking whether certain `session` key (for example, `session[:username]`) exists. In my opinion, this choice has three advantages:
  - It is more secure since whoever trying to fake a sign-in state cannot simply create a session key with a random value
  - For security purposes, we don't need to store anything meaningful in the session data, `session_id` is a perfect choice here
  - Being able to control session expiry if neccessary

  However, the trade-off here is one more query to the database for each request, including redirects. For a small scale app, I think this is acceptable.

- Classes and how they interact with different components of the app

  Specifically, I opt to create 3 classes for both `item` and `product` entities. For example, for the `item` entity:
    - `Item` class stores data of a single item, including `product_id`, `best_before_date` etc, with interfaces to read these data
    - `Items` class that stores a collection of `Item` instances. It mixes in the `Enumerable` module and provides various common collection methods: `<`, `each`, `count` etc.
    - `ItemHandler` class that interacts with the database, and create `Items` and `Item` objects so they could be used in Sinatra and `erb` files

  Alternatively, we could also simply creating only one class that interacts with the database, and returns a `PG::Result` object to Sinatra so we could extract data by iterating through it. However, I think former approach is more intuitive and maintainable than dealing with `PG::Result` and `tuple`s, and it has two advantages:

  First, everything stored in a `Tuple` object is `String` objects, which is not always intuitive or even what we want. For example, I may want to count the number of in-stock items and use it to determine how many pages we need. If we rely on the `Tuple` object, we need to remember to call `to_i` somewhere in Sinatra or the `erb` files, even at multiple places. It makes the codebase hard to maintain. By using `ItemHandler` class, we can implement our own interface and make sure the return value is always integer.

  Another advantage I could think of is the code will be more DRY and easier to maintain in case our schema changes.

  However, the trade-off here is code readability, which could be improved by using comments and proper documentation.

## Hope you enjoy the app as much as I enjoy creating it!
