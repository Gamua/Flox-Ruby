## Author:    Daniel Sperl
## Copyright: Copyright 2014 Gamua
## License:   Simplified BSD

require 'flox'
require 'test/unit'

class EntityTest < Test::Unit::TestCase

  def test_init
    type = "type"
    id = "id"
    data = { value: true }
    entity = Flox::Entity.new(type, id, data)
    assert_equal(type, entity.type)
    assert_equal(id, entity.id)
    assert_equal(data[:value], entity[:value])
    assert_not_nil(entity.created_at)
    assert_not_nil(entity.updated_at)
    assert_not_nil(entity.public_access)
  end

  def test_init_without_id
    entity = Flox::Entity.new("type")
    assert_kind_of(String, entity.id)
    assert_not_empty(entity.id)
  end

  def test_created_at
    created_at = Time.parse("2014-02-20T11:00:00Z")
    created_at_string = created_at.to_xs_datetime
    entity = Flox::Entity.new('type', 'id')
    entity['createdAt'] = created_at_string
    assert_equal(created_at, entity.created_at)
  end

  def test_updated_at
    updated_at = Time.parse("2014-02-20T11:00:00Z")
    updated_at_string = updated_at.to_xs_datetime
    entity = Flox::Entity.new('type', 'id')
    entity['updatedAt'] = updated_at_string
    assert_equal(updated_at, entity.updated_at)
  end

  def test_public_access
    entity = Flox::Entity.new('type', 'id')
    assert_equal('', entity.public_access)
    entity.public_access = 'rw'
    assert_equal('rw', entity.public_access)
  end

  def test_accepts_string_or_symbol
    first_name = 'donald'
    last_name  = 'duck'
    entity = Flox::Entity.new('type', 'id',
      { first_name: first_name, "last_name" => last_name })
    assert_equal(first_name, entity[:first_name])
    assert_equal(first_name, entity['first_name'])
    assert_equal(last_name, entity[:last_name])
    assert_equal(last_name, entity['last_name'])
  end

end