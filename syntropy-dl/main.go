package main

import (
	"context"
	"log"
	"log/slog"
	"os"
	"os/signal"

	"github.com/syntropynet/data-layer-sdk/pkg/options"
	"github.com/syntropynet/data-layer-sdk/pkg/service"
)

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt)
	defer stop()

	// See: https://docs.syntropynet.com/build/dl-access-points
	natsUrl := "nats://europe-west3-gcp-dl-testnet-brokernode-frankfurt01.syntropynet.com"
	// See: https://docs.syntropynet.com/build/data-layer/data-streams/data-layer-topics
	natsSubject := ">"
	// See: https://docs.syntropynet.com/build/data-layer/developer-portal/subscribe-to-streams#9-find-your-access-key
	natsNkey := "your-access-key"

	nkey, jwt, err := CreateUser(natsNkey)
	if err != nil {
		log.Fatalf("failed to create user from account: %v", err)
	}

	conn, err := options.MakeNats("Streams Subscriber", natsUrl, "", *nkey, *jwt, "", "", "")
	if err != nil {
		log.Fatalf("failed creating NATS connection: %v", err)
	}

	slog.Info("Connected to", "NATS", natsUrl)

	sub, err := NewSubscriber(natsSubject, service.WithContext(ctx), service.WithSubNats(conn))
	if err != nil {
		log.Fatalf("failed to init subscriber: %v", err)
	}

	sub.Start()

	for range ctx.Done() {
		// noop
	}
}
