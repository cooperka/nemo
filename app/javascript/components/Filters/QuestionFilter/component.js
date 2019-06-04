import React from 'react';
import PropTypes from 'prop-types';
import Button from 'react-bootstrap/Button';
import OverlayTrigger from 'react-bootstrap/OverlayTrigger';
import { inject, observer } from 'mobx-react';

import { getButtonHintString, getItemNameFromId } from '../utils';
import ConditionSetFormField from '../../conditions/ConditionSetFormField/component';
import FilterPopover from '../FilterPopover/component';

@inject('filtersStore')
@observer
class QuestionFilter extends React.Component {
  static propTypes = {
    filtersStore: PropTypes.object,
    onSubmit: PropTypes.func.isRequired,
  };

  async componentDidMount() {
    const { filtersStore } = this.props;
    await filtersStore.updateRefableQings();
  }

  renderPopover = () => {
    const { onSubmit } = this.props;

    return (
      <FilterPopover
        className="wide display-logic-container"
        id="question-filter"
        onSubmit={onSubmit}
        buttonsContainerClass="condition-margin"
      >
        <ConditionSetFormField />
      </FilterPopover>
    );
  }

  render() {
    const { filtersStore: { conditionSetStore } } = this.props;
    const { originalConditions, refableQings } = conditionSetStore;
    const hints = originalConditions
      .filter(({ leftQingId }) => leftQingId)
      .map(({ leftQingId }) => getItemNameFromId(refableQings, leftQingId, 'code'));

    return (
      <OverlayTrigger
        id="question-filter"
        containerPadding={25}
        overlay={this.renderPopover()}
        placement="bottom"
        rootClose
        trigger="click"
      >
        <Button id="question-filter" variant="secondary" className="btn-margin-left">
          {I18n.t('filter.question') + getButtonHintString(hints)}
        </Button>
      </OverlayTrigger>
    );
  }
}

export default QuestionFilter;
