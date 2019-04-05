import queryString from 'query-string';
import React from 'react';
import PropTypes from 'prop-types';

import ConditionValueField from './ConditionValueField';
import FormSelect from './FormSelect';

class ConditionFormField extends React.Component {
  static propTypes = {
    hide: PropTypes.bool.isRequired,

    // TODO: Describe these prop types.
    /* eslint-disable react/forbid-prop-types */
    formId: PropTypes.any,
    conditionableId: PropTypes.any,
    conditionableType: PropTypes.any,
    optionSetId: PropTypes.any,
    optionNodeId: PropTypes.any,
    value: PropTypes.any,
    namePrefix: PropTypes.any,
    index: PropTypes.any,
    id: PropTypes.any,
    refQingId: PropTypes.any,
    refableQings: PropTypes.any,
    op: PropTypes.any,
    operatorOptions: PropTypes.any,
    /* eslint-enable */
  };

  constructor(props) {
    super(props);

    const {
      formId,
      conditionableId,
      conditionableType,
      optionSetId,
      optionNodeId,
      value,
      namePrefix,
      index,
      id,
      refQingId,
      refableQings,
      op,
      operatorOptions,
    } = this.props;

    this.state = {
      formId,
      conditionableId,
      conditionableType,
      optionSetId,
      optionNodeId,
      value,
      namePrefix,
      index,
      id,
      refQingId,
      refableQings,
      op,
      operatorOptions,
    };
  }

  getFieldData = async (refQingId) => {
    ELMO.app.loading(true);
    const url = this.buildUrl(refQingId);
    try {
      // TODO: Decompose magical `response` before setting state.
      const response = await $.ajax(url);

      // Need to put this before we set state because setting state may trigger a new one.
      ELMO.app.loading(false);

      // We set option node ID to null since the new refQing may have a new option set.
      this.setState(Object.assign(response, { optionNodeId: null }));
    } catch (error) {
      ELMO.app.loading(false);
      console.error('Failed to getFieldData:', error);
    }
  }

  updateFieldData = (refQingId) => {
    this.getFieldData(refQingId);
  }

  buildUrl = (refQingId) => {
    const { id, formId, conditionableId, conditionableType } = this.state;
    const params = {
      condition_id: id || '',
      ref_qing_id: refQingId,
      form_id: formId,
      conditionable_id: conditionableId || undefined,
      conditionable_type: conditionableId ? conditionableType : undefined,
    };
    const url = ELMO.app.url_builder.build('form-items', 'condition-form');
    return `${url}?${queryString.stringify(params)}`;
  }

  formatRefQingOptions = (refQingOptions) => {
    return refQingOptions.map((o) => {
      return { id: o.id, name: `${o.fullDottedRank}. ${o.code}`, key: o.id };
    });
  }

  handleRemoveClick = () => {
    this.setState({ remove: true });
  }

  buildValueProps = (namePrefix, idPrefix) => {
    const { optionSetId, optionNodeId, value } = this.state;

    if (optionSetId) {
      return {
        type: 'cascading_select',
        namePrefix,
        for: `${idPrefix}_value`, // Not a mistake; the for is for value; the others are for selects
        id: `${idPrefix}_option_node_ids_`,
        key: `${idPrefix}_option_node_ids_`,
        optionSetId,
        optionNodeId,
      };
    }

    return {
      type: 'text',
      name: `${namePrefix}[value]`,
      for: `${idPrefix}_value`,
      id: `${idPrefix}_value`,
      key: `${idPrefix}_value`,
      value: value || '',
    };
  }

  shouldDestroy = () => {
    const { hide } = this.props;
    const { remove } = this.state;
    return remove || hide;
  }

  render() {
    const { namePrefix: rawNamePrefix, index, id, refQingId, refableQings, op, operatorOptions } = this.state;
    const namePrefix = `${rawNamePrefix}[${index}]`;
    const idPrefix = namePrefix.replace(/[[\]]/g, '_');
    const idFieldProps = {
      type: 'hidden',
      name: `${namePrefix}[id]`,
      id: `${idPrefix}_id`,
      key: `${idPrefix}_id`,
      value: id || '',
    };
    const refQingFieldProps = {
      name: `${namePrefix}[ref_qing_id]`,
      key: `${idPrefix}_ref_qing_id`,
      value: refQingId || '',
      options: this.formatRefQingOptions(refableQings),
      prompt: I18n.t('condition.ref_qing_prompt'),
      onChange: this.updateFieldData,
    };
    const operatorFieldProps = {
      name: `${namePrefix}[op]`,
      key: `${idPrefix}_op`,
      value: op || '',
      options: operatorOptions,
      includeBlank: false,
    };
    const destroyFieldProps = {
      type: 'hidden',
      name: `${namePrefix}[_destroy]`,
      id: `${idPrefix}__destroy`,
      key: `${idPrefix}__destroy`,
      value: this.shouldDestroy() ? '1' : '0',
    };
    const valueFieldProps = this.buildValueProps(namePrefix, idPrefix);

    return (
      <div
        className="condition-fields"
        style={{ display: this.shouldDestroy() ? 'none' : '' }}
      >
        <input {...idFieldProps} />
        <input {...destroyFieldProps} />
        <FormSelect {...refQingFieldProps} />
        <FormSelect {...operatorFieldProps} />
        <div className="condition-value">
          <ConditionValueField {...valueFieldProps} />
        </div>
        <div className="condition-remove">
          {/* TODO: Improve a11y. */}
          {/* eslint-disable-next-line */}
          <a onClick={this.handleRemoveClick}>
            <i className="fa fa-close" />
          </a>
        </div>
      </div>
    );
  }
}

export default ConditionFormField;
