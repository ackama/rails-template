import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import React from 'react';
import { Form } from '../../../components/utils';

describe('Form', () => {
  it('renders children', () => {
    const { container } = render(
      <Form onSubmit={jest.fn()}>
        <div>Hello World</div>
      </Form>
    );

    expect(container).toHaveTextContent('Hello World');
  });

  describe('when the form is submitted', () => {
    const handleSubmit = jest.fn();

    beforeEach(() => {
      // jsdom doesn't implement the default submit event which doesn't cause tests to
      // fail but does log a noisy message, so we use preventDefault to prevent this
      handleSubmit.mockImplementation(
        (event: React.FormEvent<HTMLFormElement>) => event.preventDefault()
      );
    });

    it('calls the submit handler once', () => {
      render(<Form onSubmit={handleSubmit} />);

      userEvent.click(screen.getByText('Submit'));

      expect(handleSubmit).toHaveBeenCalledTimes(1);
    });

    it('calls the submit handler with the event', () => {
      render(<Form onSubmit={handleSubmit} />);

      userEvent.click(screen.getByText('Submit'));

      expect(handleSubmit).toHaveBeenCalledWith(
        expect.objectContaining({
          target: expect.any(HTMLFormElement) as HTMLFormElement,
          type: 'submit'
        })
      );
    });
  });

  describe('the submitText prop', () => {
    describe('when the prop is provided', () => {
      it('uses the value for the submit button', () => {
        const { container } = render(
          <Form submitText="Submit this form please" onSubmit={jest.fn()} />
        );

        expect(container).toHaveTextContent('Submit this form please');
      });
    });

    describe('when the prop is absent', () => {
      it('uses a sensible default value', () => {
        const { container } = render(<Form onSubmit={jest.fn()} />);

        expect(container).toHaveTextContent('Submit');
      });
    });
  });

  describe('the onReset prop', () => {
    describe('when the prop is present', () => {
      it('has a reset button', () => {
        render(<Form onSubmit={jest.fn()} onReset={jest.fn()} />);

        expect(screen.getByText('Reset')).toBeInTheDocument();
      });

      describe('when the reset button is clicked', () => {
        it('calls the reset handler once', () => {
          const handleReset = jest.fn();

          render(<Form onSubmit={jest.fn()} onReset={handleReset} />);

          userEvent.click(screen.getByText('Reset'));

          expect(handleReset).toHaveBeenCalledTimes(1);
        });
      });
    });

    describe('when the prop is absent', () => {
      it('does not have a reset button', () => {
        const { container } = render(<Form onSubmit={jest.fn()} />);

        expect(container).not.toHaveTextContent('Reset');
      });
    });
  });
});
