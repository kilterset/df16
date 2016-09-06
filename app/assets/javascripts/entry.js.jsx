(function(){
  var container = document.getElementById('app')
  var CLOUDINARY_ID = 'iq7euzib'
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
    contacts: [],
    filter: ''
  }
  function reducer (state, action) {
    switch (action.type) {
      case 'SET_CONTACTS':
        return { contacts: action.contacts, filter: state.filter }
      case 'FILTER_CONTACTS':
        return { contacts: state.contacts, filter: action.filter }
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

  function contactFilterChanged(filter) {
    return {
      type: 'FILTER_CONTACTS',
      filter: filter
    }
  }

  function uploadingImage(contactId) {
    return {
      type: 'UPLOADING_IMAGE',
      contactId: contactId
    }
  }
  function imageUploaded(contactId) {
    return  {
      type: 'IMAGE_UPLOADED',
      contactId: contactId
    }
  }
  function imageUploadFailed(contactId) {
    return  {
      type: 'IMAGE_UPLOAD_FAILED',
      contactId: contactId
    }
  }
  function updatingContact(contactId) {
    return  {
      type: 'UPDATING_CONTACT',
      contactId: contactId
    }
  }
  function contactUpdated(contactId) {
    return  {
      type: 'CONTACT_UPDATED',
      contactId: contactId
    }
  }
  function contactUpdateFailed(contactId) {
    return  {
      type: 'CONTACT_UPDATE_FAILED',
      contactId: contactId
    }
  }
  function fetchContacts() {
    return function (dispatch, getState) {
      var filter = getState().filter
      var queryParams = ''
      if (filter.length > 0) {
        queryParams = '?interests='+filter
      }
      fetch('/api/contacts'+queryParams).then((resp) => {
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

  function updateContact(contactId, changedAttrs) {
    return (dispatch) => {
      var options = {
        method: 'PATCH',
        body: JSON.stringify(changedAttrs),
        headers: { 'Content-Type': 'application/json' }
      }
      fetch('/api/contacts/' + contactId, options).then((resp) => {
        if (resp.ok) {
          return resp.json()
        }
        return Promise.reject('contact update failed')
      }).then((body) => {
        dispatch(contactChanged(body))
      }).catch((err) => {
        console.log(err)
      })
    }
  }

  function uploadImage (file, contact) {
    var contactId = contact.id
    var data = new window.FormData()
    data.append('file', file)
    data.append('upload_preset', CLOUDINARY_ID)
    return (dispatch, getState) => {
      dispatch(uploadingImage(contactId))
      fetch(
        'https://api.cloudinary.com/v1_1/huxfscq7g/image/upload',
        { method: 'post', body: data }
      ).then(function (resp) {
        if (resp.status !== 200) {
          return Promise.reject(new Error('unable to upload photo'))
        }
        return resp.json()
      }).then(function (json) {
        console.log(json)
        dispatch(imageUploaded(contactId))
        dispatch(updateContact(contactId, {photo_url: json.secure_url}))
      }).catch(function (error) {
        console.log(error)
        dispatch(imageUploadFailed(contactId))
      })
    }
  }

  // Components

  var Contact = React.createClass({
    fileChanged (e) {
      var target = e.target
      var files = target.files
      if (files.length > 0) {
        var file = files[0]
        this.props.dispatch(uploadImage(file, this.props.data))
      }
    },
    render () {
      var contact = this.props.data
      var url = contact.photo_url
      var image = url ? <img src={url} alt='contact image'/> : null
      return (
        <div>
          <h1>{contact.name}</h1>
          {image}
          <input type='file' onChange={this.fileChanged} />
          {contact.interests}
        </div>
      )
    }
  })

  var ContactList = React.createClass({
    filterChanged (element) {
      this.props.dispatch(contactFilterChanged(element.target.value))
      this.props.dispatch(fetchContacts())
    },
    render () {
      var contacts = this.props.contacts
      var filter = this.props.filter
      return (
        <div>
          <label>
            Filter interests:
            <input value={filter} onChange={this.filterChanged}/>
          </label>
          {contacts.map((contact) => <Contact key={contact.id} data={contact} dispatch={this.props.dispatch}/> )}
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
      var storeState = this.state.storeState
      var contacts = storeState.contacts
      var filter = storeState.filter
      var dispatch = this.props.store.dispatch
      return (
        <div>
          <h1>Interested.io</h1>
          <hr/>
          <ContactList contacts={contacts} filter={filter} dispatch={dispatch}/>
        </div>
      )
    }
  })

  // Init app

  window.store = Store(reducer)
  ReactDOM.render(<App store={store}/>, container)
}())
