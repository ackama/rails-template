import React from 'react';

interface Props {
  submitText?: string;

  onSubmit: (event: React.FormEvent<HTMLFormElement>) => void;
  onReset?: () => void;
}

export const Form: React.FC<Props> = props => (
  <form onSubmit={props.onSubmit} onReset={props.onReset}>
    {props.children}
    <br />
    <input type="submit" value={props.submitText ?? 'Submit'} />
    {props.onReset && <input type="reset" value="Reset" />}
  </form>
);
