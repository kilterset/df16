(function(){
  var container = document.getElementById('app')

  if (!window.fetch) {
    alert('JS fetch API is required for this site! Please use a modern browser such as chrome.')
  }

  // Store

  function Store (reducer, middleware) {
    var listeners = []
    var state = reducer(undefined, {type: 'INIT_STORE'})
    var middleware = middleware || []
    var store = {
      subscribe (callback) {
        listeners.push(callback)
        callback(state)
      },
      dispatch (action) {
        if (typeof action === 'function') {
          action(store.dispatch, store.getState)
        } else {
          state = reducer(state, action)
          listeners.forEach(function (listener) {
            listener(state)
          })
        }
      },
      getState () {
        return state
      }
    }
    return store
  }

  // Reducers

  var DEFAULT_STATE = {
    contacts: []
  }
  function reducer (state, action) {
    switch (action.type) {
      case 'SET_CONTACTS':
        return { contacts: action.contacts }
    }
    return state || DEFAULT_STATE
  }

  // Actions

  function setContacts(contacts) {
    return {
      type: 'SET_CONTACTS',
      contacts: contacts
    }
  }
  function fetchContacts() {
    return function (dispatch) {
      fetch('/api/contacts').then((resp) => {
        if (resp.ok) {
          return resp.json()
        } else {
          return Promise.reject('Unable to fetch contacts')
        }
      }).then((body) => {
        dispatch(setContacts(body.data))
      }).catch((err) => {
        console.log(err)
      })
    }
  }
  // Components

  var Contact = React.createClass({
    render () {
      var contact = this.props.data
      var interests = contact.interests.split(' ')
      var url = contact.photo_url
      var image = url ? <img src={url} alt='contact image'/> : null
      return (
        <div>
          <h1>{contact.name}</h1>
          {image}
          {interests.join(', ')}
        </div>
      )
    }
  })

  var ContactList = React.createClass({
    render () {
      var contacts = this.props.contacts
      return (
        <div>
          {contacts.map((contact) => <Contact key={contact.id} data={contact} /> )}
        </div>
      )
    }
  })

  var App = React.createClass({
    componentWillMount() {
      var store = this.props.store
      store.subscribe(this.storeChanged)
      store.dispatch(fetchContacts())
    },
    storeChanged(state) {
      this.setState({ storeState: state })
    },
    render () {
      var contacts = this.state.storeState.contacts
      return (
        <div>
          <h1>Interested.io</h1>
          <hr/>
          <ContactList contacts={contacts}/>
        </div>
      )
    }
  })

  // Init app

  window.store = Store(reducer)
  ReactDOM.render(<App store={store}/>, container)
}())
