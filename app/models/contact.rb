#encoding:utf-8
class Contact < ActiveRecord::Base    
  require "unicode_utils/upcase"
   
  belongs_to :user 
  has_many :credits, :dependent => :destroy
               
  validates :user_id, :presence => true
  validates :first_name, :presence => {:message => "boş olmamalıdır."}
  validates :last_name, :presence => {:message => "boş olmamalıdır."}
  validates :email, :presence => {:message => "boş olmasın ki borçlarını hatırlatalım."}
  validates :email, :format => {:with => /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i, :message => "gerçerli değil !"}, :if => "email.present?"                   
                   

  scope :borclular, where(["debt > 0"])      
  scope :alacaklilar, where(["debt < 0"])                
  scope :vadesine_gore_borclular, lambda { |tarih=nil| includes(:credits).where(['debt > 0 and credits.date_to <= ?', "#{tarih}"]) }
                   
  def name
    "#{first_name.capitalize} #{UnicodeUtils.upcase(last_name, :tr)}"    
  end                                                        
  
  def lock_status
    lock ? "Evet" : "Hayır"
  end   
  
  def self.refresh_debt(contact)
    borc = contact.credits.where(:credit_type => 1).sum(:amount)
    alacak = contact.credits.where(:credit_type => 2).sum(:amount)
    contact.update_attributes(:debt => borc-alacak)
  end
                   
end
