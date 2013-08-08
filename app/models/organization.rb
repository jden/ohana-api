class Organization
  include RocketPants::Cacheable
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search

  search_in :name, :agency, :description, :keywords

  normalize_attributes :agency, :city, :description, :eligibility_requirements,
    :fees, :how_to_apply, :name, :service_hours, :service_wait,
    :services_provided, :street_address, :target_group,
    :transportation_availability, :zipcode

  field :accessibility_options, type: Array
  field :agency, type: String
  field :ask_for, type: Array
  field :city, type: String
  field :coordinates, type: Array
  field :description, type: String
  field :eligibility_requirements, type: String
  field :emails, type: Array
  field :faxes, type: Array
  field :fees, type: String
  field :funding_sources, type: Array
  field :how_to_apply, type: String
  field :keywords, type: Array
  field :languages_spoken, type: Array
  field :leaders, type: Array
  field :market_match, type: Boolean
  field :name, type: String
  field :payments_accepted, type: Array
  field :phones, type: Array
  field :products_sold, type: Array
  field :service_areas, type: Array
  field :service_hours, type: String
  field :service_wait, type: String
  field :services_provided, type: String
  field :state, type: String
  field :street_address, type: String
  field :target_group, type: String
  field :transportation_availability, type: String
  field :ttys, type: Array
  field :urls, type: Array
  field :zipcode, type: String

  validates_presence_of :name

  extend ValidatesFormattingOf::ModelAdditions
  validates_formatting_of :zipcode, using: :us_zip,
                            allow_blank: true,
                            message: "%{value} is not a valid ZIP code"

  validates :phones, hash:  {
    format: { with: /\A(\((\d{3})\)|\d{3})[ |\.|\-]?(\d{3})[ |\.|\-]?(\d{4})\z/,
              allow_blank: true,
              message: "Please enter a valid US phone number" } }

  validates :emails, array: {
    format: { with: /.+@.+\..+/i,
              message: "Please enter a valid email" } }

  validates :urls, array: {
    format: { with: /(?:(?:http|https):\/\/)?([-a-zA-Z0-9.]{2,256}\.[a-z]{2,4})\b(?:\/[-a-zA-Z0-9@:%_\+.~#?&\/\/=]*)?/i,
              message: "Please enter a valid URL" } }

  include Geocoder::Model::Mongoid
  geocoded_by :address               # can also be an IP address
  #after_validation :geocode          # auto-fetch coordinates

  scope :find_by_category, lambda { |category| where(keywords: /#{category.strip}/i) }
  scope :find_by_language, lambda { |language| where(languages_spoken: /#{language.strip}/i) }

  #combines address fields together into one string
  def address
    "#{self.street_address}, #{self.city}, #{self.state} #{self.zipcode}"
  end

  #NE and SW geo coordinates that define the boundaries of San Mateo County
  SMC_BOUNDS = [[37.1074,-122.521], [37.7084,-122.085]].freeze

  # Google provides a "bounds" option to restrict the address search to
  # a particular area. Since this app focues on organizations in San Mateo
  # County, we use SMC_BOUNDS to restrict the search.
  def self.find_near(location, radius)
    result = Geocoder.search(location, :bounds => SMC_BOUNDS)
    coords = result.first.coordinates if result.present?
    near(coords, radius)
  end
end