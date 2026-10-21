class Post < ApplicationRecord
  enum :status, { draft: 0, published: 1 }
  has_many :comments
end
