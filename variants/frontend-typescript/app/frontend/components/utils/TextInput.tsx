import React, { useCallback } from 'react';

interface Props {
  id: string;
  label: string;
  value: string;
  required?: boolean;

  onChange: (value: string) => void;
}

export const TextInput: React.FC<Props> = props => {
  const { onChange } = props;
  const handleChange = useCallback<React.ChangeEventHandler<HTMLInputElement>>(
    event => onChange(event.target.value),
    [onChange]
  );

  return (
    <label htmlFor={props.id}>
      {props.label}:
      <input
        id={props.id}
        type="text"
        value={props.value}
        required={props.required}
        onChange={handleChange}
      />
    </label>
  );
};
