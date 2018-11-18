# RPATeachable Gem
This gem was created as part of a technical evaluation at Teachable.com.

## RPATeachable::List
### Methods
  - #new
  ```
  list = RPATeachable::List.new(name: 'my list')
  ```
  - #save
  ```
  list.save
  ```
  This creates the list on the Teachable API.
  - #items
  This returns an array of the items in this list. Ojbects in the Array are of type
  `RPATeachable::List::Item`
  - #name
  Returns the name
  - #add_item
  ```
  list.add_item(name: 'my item')
  ```
  This will make an API call to create the item. Returns a `RPATeachable::List::Item`

## RPATeachable::List::Item
### Methods
  - #new
  - #save
  - #name
  - #finished?
  - #finished_at
