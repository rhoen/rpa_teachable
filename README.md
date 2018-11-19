# RPATeachable Gem
This gem was created as part of a technical evaluation at Teachable.com.

## Configuration
To use the gem you must set your username and password as follows:
```
RPATeachable.user_name = 'user_name'
RPATeachable.password = 'password'
```

## Specs
Unit tests can be run using rspec with the command `$ rspec spec/unit/`.
The acceptance tests will make api requests against the teachable api. To run you must first add credentials to the file `/spec/acceptance/acceptance_spec.rb`. You can run the acceptance tests with the command `$ rspec spec/acceptance`

## Errors
The RPATeachable gem can raise the following errors.
- `RPATeachable::UnprocessableError` => when the API returns a 422 due to bad input.
- `RPATeachable::CredentialsNotSetError` => when you try to access the API without setting credentials.
- `RPATeachable::AuthenticationError` => when the API returns a 401.
- `RPATeachable::ApiServerError` => when the API returns a 500.
- `Net::OpenTimeout` => when the HTTP library times out.

## RPATeachable::List
### Methods
  - .all
  ```
  RPATeachable::List.all
  ```
  Fetches all lists for the user. Returns an array, items in the array are instances of `RPATeachable::List`.
  - #new
  ```
  RPATeachable::List.new(name: 'my list')
  ```
  Returns an instance of RPATeachable::List.
  - #save
  Creates the list on the Teachable API. If the list has already been saved, a patch request will be sent to update the list. The name of the list can be changed in this way.
  - #items
  Fetches the current list from the Teachable API. It returns an array. Objects in the Array are instances of
  `RPATeachable::List::Item`
  - #name
  Returns the name
  - #name=
  Give a new name to the list. Must call save before it will be persisted on the API.
  - #id
  Returns the id.
  - #src
  Returns the api url for the list.
  - #add_item
  ```
  list.add_item(name: 'my item')
  ```
  This will make an API call to create the item. Returns a `RPATeachable::List::Item`
  - #delete
  This will make an API call to delete the list and all of it's items.

## RPATeachable::List::Item
### Methods
  - #new
  ```
  RPATeachable::List::Item.new(name: 'my item', list: list)
  ```
  Instantiates an item. Name and list are required.
  - #save
  Creates the list list on the Teachable API.
  - #name
  Returns the name.
  - #id
  Returns the id.
  - #src
  Returns the api url for the item.
  - #finish
  Makes an API call to mark the item as Finished. Will also make a fetch against the API in order to set finished_at.
  - #finished_at
  Returns an instance of `Time` of the time the item was finished. Will be nil if the item has not been finished.
  - #delete this will make an API call to delete the item.
