# Polymorphic Associations

A [polymorphic association](http://guides.rubyonrails.org/association_basics.html#polymorphic-associations) is a special kind of `belongs_to` association that can point to *any* model class.

Think of Facebook comments: They are a single concept but can be attached to many different things, like statuses, links, images, etc. We could say that a comment `belongs_to :status` and `belongs_to :link` and so on, creating associations for every possible target... but this would quickly get awkward. Instead we can use a single polymorphic association that refers to "the thing that this comment is attached to", or the "commentable".

The workings of polymorphic associations are very well-documented on the ActiveRecord side, but there are no strong conventions for dealing with them in your routes and controllers. The approach we'll take in this demo is, we think, a good one, but it is not "standard" by any means.

## Demo: Comments

The app in this repo is an extremely low-rent social network that allows signed-in users to post statuses and links. We would like users to also be able to post comments on both of these things.

```
$ rails g migration CreateComments
```

```ruby
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

```ruby
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

Now to link up the other ends of the relationships:

```ruby
# Add this to user.rb
has_many :comments
```

```ruby
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

At this point it might help to add a display of comments to the actual app:

```erb
<% # Add to the bottom of app/views/links/show.html.erb %>
<%= render @link.comments %>
```

```erb
<% # Add to the bottom of app/views/statuses/show.html.erb %>
<%= render @status.comments %>
```

```erb
<% # Create this in app/views/comments/_comment.html.erb %>
<p>
  <i><%= comment.user.email %> commented:</i><br>
  <%= comment.content %>
</p>
```

You should now be able to start the app, go to the "comments" link for a status or link, and view the comments you created in the console.

### Routes and Forms

Since we need a status or link to create a comment, it would make sense to nest the route for comment creation under those resources. We'll put the form for comment creation directly on the status/link page, so we only need to worry about the `create` route.

```ruby
Rails.application.routes.draw do
  devise_for :users

  resources :statuses, only: [:show, :new, :create] do
    resources :comments, only: :create
  end

  resources :links, only: [:show, :new, :create] do
    resources :comments, only: :create
  end

  root 'home#show'
end
```

```
$ rake routes
                  Prefix Verb   URI Pattern                                 Controller#Action
        new_user_session GET    /users/sign_in(.:format)                    devise/sessions#new
            user_session POST   /users/sign_in(.:format)                    devise/sessions#create
    destroy_user_session DELETE /users/sign_out(.:format)                   devise/sessions#destroy
cancel_user_registration GET    /users/cancel(.:format)                     devise/registrations#cancel
       user_registration POST   /users(.:format)                            devise/registrations#create
   new_user_registration GET    /users/sign_up(.:format)                    devise/registrations#new
  edit_user_registration GET    /users/edit(.:format)                       devise/registrations#edit
                         PATCH  /users(.:format)                            devise/registrations#update
                         PUT    /users(.:format)                            devise/registrations#update
                         DELETE /users(.:format)                            devise/registrations#destroy
         status_comments POST   /statuses/:status_id/comments(.:format)     comments#create
      new_status_comment GET    /statuses/:status_id/comments/new(.:format) comments#new
                statuses POST   /statuses(.:format)                         statuses#create
              new_status GET    /statuses/new(.:format)                     statuses#new
                  status GET    /statuses/:id(.:format)                     statuses#show
           link_comments POST   /links/:link_id/comments(.:format)          comments#create
        new_link_comment GET    /links/:link_id/comments/new(.:format)      comments#new
                   links POST   /links(.:format)                            links#create
                new_link GET    /links/new(.:format)                        links#new
                    link GET    /links/:id(.:format)                        links#show
                    root GET    /                                           home#show
```

There's a small problem here: Both sets of nested routes map to the same actions in the same controller (which we haven't created yet). Once in the controller, we'll need some other way to determine whether the new comment should be attached to a status or a link.

We'll worry about this later &ndash; for now, let's build the new comment form:

```erb
<% # Create this in app/views/comments/new.html.erb %>
<%= form_for [@commentable, @comment] do |f| %>
  <div class="field">
    <%= f.label :content, 'Write a comment' %><br>
    <%= f.text_area :content %>
  </div>
  <div class="actions">
    <%= f.submit %>
  </div>
<% end %>
```

Note the parameter to `form_for` is an array rather than a single object. Rails will inspect the class of each object and use that to construct the path that the form will be submitted to. So if the `@commentable` is a Status, and `@comment` is a new Comment, Rails will look for a `status_comments_path` (which you'll note we have). This allows the same form to submit to multiple paths, depending on the objects passed in.

Now we just need a link to this form before we can get started on the controller:

```erb
<% # Add to the bottom of app/views/links/show.html.erb %>
<p><%= link_to 'Leave a comment', new_link_comment_path(@link) %></p>
```

```erb
<% # Add to the bottom of app/views/statuses/show.html.erb %>
<p><%= link_to 'Leave a comment', new_status_comment_path(@status) %></p>
```

### The Controller

Finally, we need to write the controller that will display and process this form. As noted above, since the same action will process new comments for both statuses and links, we need a way to find the correct "target" model for the polymorphic association.

```ruby
class CommentsController < ApplicationController
  def new
    @commentable = commentable
    @comment = Comment.new
  end

  def create
    @commentable = commentable
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    @comment.commentable = @commentable

    if @comment.save
      redirect_to @commentable, notice: 'Comment posted!'
    else
      flash.now[:alert] = @comment.errors.full_messages.join(', ')
      render :new
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end

  def commentable
    commentable_type.camelize.constantize.find(commentable_id)
  end

  def commentable_id
    params["#{commentable_type}_id"]
  end

  def commentable_type
    %w(status link).detect{ |type| params["#{type}_id"].present? }
  end
end
```

Let's take the process of finding the "target" model one step at a time, starting from the bottom:

* First we need to find out whether we have a `params[:status_id]` or a `params[:link_id]`. The `commentable_type` method does this and returns the string `'status'` or `'link'` as appropriate.
* Then we need to actually fetch the status ID or link ID from the params. The `commentable_id` method does this.
* Finally, combining these two pieces of information, the `commentable` method transforms the type string into a constant and calls `.find` on it, passing the ID from the params.

The rest of the controller works pretty much the same as all the other controllers we've written to date &ndash; the tricky part is getting the "commentable" in the first place.

### Checkpoint

The `done-comments` branch contains all work completed up to this point.

## Lab: Likes

Let's say we now want to allow signed-in users to "like" both statuses and links. In some respects this will be easier than commenting, since there will be no separate "new like" page with a form on it &ndash; we can just have a button that directly likes or un-likes the model in question, with no possibility of validation errors.
