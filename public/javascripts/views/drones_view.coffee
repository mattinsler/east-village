class GithubRepositories extends Backbone.Collection
  url: '/api/repos'

class GithubRepositoryView extends Backbone.View
  template: @template('github_repository')
  tagName: 'tr'
  initialize: -> Spellbinder.initialize(@)

class App.DronesView extends Backbone.View
  template: @template('drones')
  
  initialize: ->
    Spellbinder.initialize(@)
    @repositories = new GithubRepositories()
    @repositories.fetch()
  
  render: ->
    @repositories_view = new CollectionView(
      el: @$('table.repositories tbody')
      item_view: GithubRepositoryView
      collection: @repositories
      sort_by: {pushed_at: 'desc'}
    )
  