# Polymorphic Associations

A [polymorphic association](http://guides.rubyonrails.org/association_basics.html#polymorphic-associations) is a special kind of `belongs_to` association that can point to *any* model class.

Think of Facebook comments: They are a single concept but can be attached to many different things, like statuses, links, images, etc. We could say that a comment `belongs_to :status` and `belongs_to :link` and so on, creating associations for every possible target... but this would quickly get awkward. Instead we can use a single polymorphic association that refers to "the thing that this comment is attached to", or the "commentable".

The workings of polymorphic associations are very well-documented on the ActiveRecord side, but there are no strong conventions for dealing with them in your routes and controllers. The approach we'll take in this demo is, we think, a good one, but it is not "standard" by any means.

## Demo: Comments

The app in this repo is an extremely low-rent social network that allows signed-in users to post statuses and links. We would like users to also be able to post comments on both of these things.

```
$ rails g migration CreateComments
```

```
class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :user
      t.references :commentable, polymorphic: true
      t.text :content
    end
  end
end
```

```
$ rake db:migrate
```

Check your schema file and you'll see that in addition to generating the expected `t.integer :commentable_id`, the "polymorphic" option also generated a `t.string :commentable_type`. This will be set to a string like `'Status'` or `'Link'` indicating the model that should be used to look up the ID. The combination of type and ID is enough to uniquely identify any model instance.

Before we can play around with this, we also need the model side of things:

```
class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  validates :content, presence: true
end
```

The only unfamiliar part of this should be the "polymorphic" option, which tells Rails that this is a polymorphic association and it should look for a corresponding `_type` column in the database.

```
$ rake db:seed
$ rails c
2.1.2 :001 > Comment.create!(user: User.first, commentable: Status.first, content: 'herp')
 => #<Comment id: 1, user_id: 1, commentable_id: 1, commentable_type: "Status", content: "herp">
2.1.2 :002 > Comment.create!(user: User.first, commentable: Link.first, content: 'derp')
 => #<Comment id: 1, user_id: 1, commentable_id: 1, commentable_type: "Link", content: "derp">
2.1.2 :003 > Comment.first.commentable
 => #<Status id: 1, user_id: 1, content: "Test status with some content", created_at: "2014-06-29 19:03:47", updated_at: "2014-06-30 19:03:47">
```

As seen here, we can now set the "commentable" of a Comment to be either a Status or a Link, and the `commentable_type` attribute is set appropriately. We can then retrieve it just like we would with an ordinary association.

Now to link up the other end of the relationship:

```
  # Add this to both status.rb and link.rb
  has_many :comments, as: :commentable
```

The `as` option tells Rails that, if we wanted to go from a Comment back to the Status or Link, we would have to call `comment.commentable` and not `comment.status` or `comment.link` as you might normally expect.

```
2.1.2 :004 > reload!
Reloading...
 => true
2.1.2 :005 > Status.first.comments
 => #<ActiveRecord::Associations::CollectionProxy [#<Comment id: 1, user_id: 1, commentable_id: 1, commentable_type: "Status", content: "herp">]>
2.1.2 :006 > Link.first.comments
 => #<ActiveRecord::Associations::CollectionProxy [#<Comment id: 2, user_id: 1, commentable_id: 1, commentable_type: "Link", content: "derp">]>
```
