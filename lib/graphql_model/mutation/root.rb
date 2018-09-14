# frozen_string_literal: true

class Mutation::Root
  def self.definition
    GraphQL::ObjectType.define do
      name 'Mutation'

      models = (Type.constants - %i[Query Base DateTime PointsEvolution Buildings])
      models.map do |model_name|
        model = Type.const_get(model_name)
        model.mutations.map do |mutation|
          field mutation.name, field: mutation.field
        end
      end
    end
  end
end
