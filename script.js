let type = '';

$(document).ready(function() {
    window.addEventListener('message', (event) => {
        if (event.data && event.data.type) {
            switch (event.data.type) {
                case 'show':
                    $('.heli').fadeIn();
                    break;
                case 'hide':
                    $('.heli').fadeOut();
                    break;
                case 'updateState':
                    if (event.data.update) {
                        if (Array.isArray(event.data.update)) {
                            event.data.update.forEach(update => {
                                $(`.control[data-control=${(update.control || '').toLowerCase()}`).attr('data-state', update.state);
                            });
                        } else {
                            $(`.control[data-control=${(event.data.update.control || '').toLowerCase()}`).attr('data-state', event.data.update.state);
                        }
                    }
                    break;
                case 'resetState':
                    $('.control').each(function(i) {
                        $(this).attr('data-state', '');
                    });
                    break;
            }
        }
    });
});

function resetState() {
    let e = new CustomEvent('message');
    e.data = {
        type: 'resetState'
    }
    window.dispatchEvent(e);
}

function setState(control, state) {
    let e = new CustomEvent('message');
    e.data = {
        type: 'updateState',
        update: {
            control: control,
            state: state
        }
    }
    window.dispatchEvent(e);
}

function setStateArray(control, state, control2, state2) {
    let e = new CustomEvent('message');
    e.data = {
        type: 'updateState',
        update: [{
            control: control,
            state: state
        }, {
            control: control2,
            state: state2
        }]
    }
    window.dispatchEvent(e);
}

function setVisibility(show) {
    let e = new CustomEvent('message');
    if (show) {
        e.data = {
            type: 'show'
        }
    } else {
        e.data = {
            type: 'hide'
        }
    }
    window.dispatchEvent(e);
}