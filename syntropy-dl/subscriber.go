package main

import (
	"context"
	"log/slog"

	"github.com/syntropynet/data-layer-sdk/pkg/options"
	"github.com/syntropynet/data-layer-sdk/pkg/service"
)

type Subscriber struct {
	streamSubject string
	*service.Service
}

func NewSubscriber(subject string, o ...options.Option) (*Subscriber, error) {
	ret := &Subscriber{
		streamSubject: subject,
		Service:       &service.Service{},
	}

	ret.Configure(o...)

	return ret, nil
}

func (s *Subscriber) Start() context.Context {
	err := s.subscribe()
	if err != nil {
		s.Fail(err)
		return s.Context
	}

	return s.Service.Start()
}

func (s *Subscriber) subscribe() error {
	slog.Info("Subscribed to", "SUBJECT", s.streamSubject)
	if _, err := s.SubscribeTo(s.handleQuery, s.streamSubject); err != nil {
		return err
	}
	s.PubNats.Flush()

	return nil
}

func (s *Subscriber) handleQuery(nmsg service.Message) {
	slog.Info("Received", "SUBJECT", nmsg.Message().Subject, "PAYLOAD", string(nmsg.Data()))
}
