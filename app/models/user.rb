class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # :recoverable is left off until production mail delivery is configured; the
  # reset_password_* columns are already in the users table for when it is.
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable
end
