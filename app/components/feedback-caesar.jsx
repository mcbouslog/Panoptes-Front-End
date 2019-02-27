import PropTypes from 'prop-types';
import React from 'react';
import Translate from 'react-translate-component';
import counterpart from 'counterpart';
import ModalFormDialog from 'modal-form/dialog';
import ModalFocus from './modal-focus';

/* eslint-disable max-len */
counterpart.registerTranslations('en', {
  FeedbackCaesar: {
    title: 'Feedback',
    ok: 'OK'
  }
});
/* eslint-enable max-len */

class FeedbackCaesar extends React.Component {
  constructor() {
    super();
    this.closeButton = null;
  }

  componentDidMount() {
    const { closeButton } = this;
    closeButton.focus && closeButton.focus();
  }

  render() {
    const { data } = this.props;
    console.log('data = ', data);
    const catCount = data["0"] ? data["0"] : 0;
    const birdCount = data["1"] ? data["1"] : 0;
    const turtleCount = data["2"] ? data["2"] : 0;

    return (
      <ModalFocus>
        <Translate content="FeedbackCaesar.title" component="h2" />
        <h3>So far others said:</h3>
        <ul>
          <li>
            Cat:
            {catCount}
          </li>
          <li>
            Bird:
            {birdCount}
          </li>
          <li>
            Turtle:
            {turtleCount}
          </li>
        </ul>

        <div className="buttons">
          <button
            className="standard-button"
            type="submit"
            ref={(button) => { this.closeButton = button; }}
          >
            <Translate content="FeedbackCaesar.ok" />
          </button>
        </div>
      </ModalFocus>
    );
  }
}

function openFeedbackCaesar({ data }) {
  const modal = (<FeedbackCaesar data={data} />);
  return ModalFormDialog.alert(modal, {
    required: true
  });
}

export default openFeedbackCaesar;
